From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: Re: [PATCH/RFC] set_rates support for prism54
Date: Sun, 15 Aug 2004 19:10:25 +0300
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200408151910.25641.vda@port.imtp.ilyichevsk.odessa.ua>
References: <5.1.0.14.2.20040815145122.00afd708@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: 7bit
Cc: mcgrof@studorgs.rutgers.edu, netdev@oss.sgi.com,
	jgarzik@pobox.com
Return-path: <prism54-devel-bounces@prism54.org>
To: margitsw@t-online.de (Margit Schubert-While),
	prism54-devel@prism54.org
In-Reply-To: <5.1.0.14.2.20040815145122.00afd708@pop.t-online.de>
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

On Sunday 15 August 2004 16:21, Margit Schubert-While wrote:
> I disagree with this.
> We don't need parameter parsing either in the driver or in
> wireless.c.
> There is a perfectly good infrastructure in wireless tools iwpriv.c
> Take a look at around line 375 in iwpriv.c for the
> existing example of IW_PRIV_TYPE_FLOAT.
> This could be adapted for this purpose (IW_PRIV_TYPE_BITRATE ?)
> and (mis)use the iw_freq structure to pass the values and extra info.

Ok. And then we will need to parse that data into format suitable for
prism54 in prism54 driver, and into format suitable for acx100/acx111
in acx100 driver, etc... Most probably this code will be ugly, because
different hardware have completely different way of setting tx rate.
Even acx100 and acx111 are different, not to say acx100 and prism54.
--
vda
