From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: Re: [PATCH/RFC] set_rates support for prism54
Date: Sun, 15 Aug 2004 21:58:06 +0300
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200408152158.06344.vda@port.imtp.ilyichevsk.odessa.ua>
References: <5.1.0.14.2.20040815145122.00afd708@pop.t-online.de>
	<200408152012.18018.vda@port.imtp.ilyichevsk.odessa.ua>
	<200408152141.48877.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: 7bit
Cc: mcgrof@studorgs.rutgers.edu, jgarzik@pobox.com,
	prism54-devel@prism54.org,
	Margit Schubert-While <margitsw@t-online.de>
Return-path: <prism54-devel-bounces@prism54.org>
To: Vladimir Kondratiev <vkondra@mail.ru>, netdev@oss.sgi.com
In-Reply-To: <200408152141.48877.vkondra@mail.ru>
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

On Sunday 15 August 2004 21:41, Vladimir Kondratiev wrote:
> DV> > For supported and optional rate, IE (info element) format may be the best
> DV> > choice.
> DV>
> DV> I did not quite understand you, can you elaborate a bit?
>
> How card know what rates it can use? It parses "supported rates" IE (info
> element) from beacon it gets from AP. My point, it is reasonable to use the
> same language to specify further restrictions. This way, we will speak the
> same language as standard do.

And advantages of doing that are .... ?

> In standard, there is no way to say "you can use PBCC, but not for rate
> 5.5". PBCC is either permitted or not. For "good" hardware, there is no
> point of doing this. You may need to artificially restrict rate/modulation
> only if hardware can't find best for current channel conditions, or, of
> course, for debug. But, I would say, for this cases, let's use debug hooks.

You can consider set_rates a debug hook. For 'normal' use, just
stick to "iwconfig rate" command.

> Mainline should be as close to standard as possible.

802.11 does not say anything about OS interface to setting basic
and operational rates. We are free to inmplement whatever we like.

Of course, I do not propose sending anything non-standard.

> It should be as generic as possible, also. Scheme you suggested is not very
> scalable.

It's much better than what we have now. "iwconfig rate" cover
only a subset of AP configuration needs. How can I, say,
diasllow 1 and 2 Mbit/s with iwconfig?

> Think of TGn that would for sure add its tricks with modulation.
> If we start combining rate with modulation, we will shortly fall into too
> many options.

I don't know what is TGn... sorry... However, adding new suffixes
would not be a problem at all.
--
vda
