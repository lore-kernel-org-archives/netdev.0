From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: Re: [PATCH/RFC] set_rates support for prism54
Date: Sun, 15 Aug 2004 20:12:18 +0300
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200408152012.18018.vda@port.imtp.ilyichevsk.odessa.ua>
References: <5.1.0.14.2.20040815145122.00afd708@pop.t-online.de>
	<200408151910.25641.vda@port.imtp.ilyichevsk.odessa.ua>
	<200408151949.01351.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: 7bit
Cc: mcgrof@studorgs.rutgers.edu, jgarzik@pobox.com,
	prism54-devel@prism54.org,
	Margit Schubert-While <margitsw@t-online.de>
Return-path: <prism54-devel-bounces@prism54.org>
To: Vladimir Kondratiev <vkondra@mail.ru>, netdev@oss.sgi.com
In-Reply-To: <200408151949.01351.vkondra@mail.ru>
Content-Disposition: inline
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Sunday 15 August 2004 19:48, Vladimir Kondratiev wrote:
> I would not mix rates with modulation and other channel parameters.
> It looks better to bind frequency with parameters like modulation, channel
> width (10Mzh narrow channels in japan) etc. , into 'channel' number or
> (channel,band) tuple.

Consider need of being able to:

set_rates "1,2 5p,11p,22p" - i.e. "use PBCC modulation"
set_rates "1,2 5,11,22p" - "use standard CCK, and PBCC only for 22Mbit"

See? Very similar, but not the same.
So, how do you propose to express this?

This need is not imagined by me, it is very real for acx100
owners.

> For supported and optional rate, IE (info element) format may be the best
> choice.

I did not quite understand you, can you elaborate a bit?
--
vda
