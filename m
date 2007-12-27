From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH] net/ipv4/netfilter/ip_tables.c: remove some inlines
Date: Thu, 27 Dec 2007 04:01:35 +0000
Message-ID: <200712270401.35983.vda.linux@googlemail.com>
References: <200712161247.53986.vda.linux@googlemail.com> <47668BE9.8010504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753362AbXL0EB4@vger.kernel.org>
In-Reply-To: <47668BE9.8010504@trash.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 17 December 2007 14:47, Patrick McHardy wrote:
> Please CC netfilter-devel on netfilter patches.
>
> Denys Vlasenko wrote:
> > Hi Patrick, Harald,
> >
> > I was working on unrelated problem and noticed that ip_tables.c
> > seem to abuse inline. I prepared a patch which removes inlines
> > except those which are used by packet matching code
> > (and thus are really performance-critical).
> > I added comments explaining that remaining inlines are
> > performance critical.
> >
> > Result as reported by size:
> >
> >    text    data     bss     dec     hex filename
> > -  6451     380      88    6919    1b07 ip_tables.o
> > +  6339     348      72    6759    1a67 ip_tables.o
> >
> > Please take this patch into netfilter queue.
>
> This clashes with my pending patches, which I'll push upstream
> today. I also spent some time resyncing ip_tables and ip6_tables
> so a diff of both (with some sed'ing) shows only the actual
> differences, so please update ip6_tables as well.

I would be happy to rediff the patch.

Which tree should I sync against in order to not collide
with your changes?
--
vda
