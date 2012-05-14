From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] [RFC] netfilter: don't assume NFPROTO_* are like PF_*
Date: Mon, 14 May 2012 21:06:35 +0200
Message-ID: <20120514190635.GE14897@1984>
References: <1337003909-2582-1-git-send-email-alban.crequy@collabora.co.uk>
 <alpine.LNX.2.01.1205141707490.11548@frira.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1205141707490.11548@frira.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 05:09:54PM +0200, Jan Engelhardt wrote:
> 
> On Monday 2012-05-14 15:58, Alban Crequy wrote:
> >--- a/include/linux/netfilter.h
> >+++ b/include/linux/netfilter.h
> >@@ -62,11 +62,11 @@ enum nf_inet_hooks {
> > 
> > enum {
> > 	NFPROTO_UNSPEC =  0,
> >-	NFPROTO_IPV4   =  2,
> >-	NFPROTO_ARP    =  3,
> >-	NFPROTO_BRIDGE =  7,
> >-	NFPROTO_IPV6   = 10,
> >-	NFPROTO_DECNET = 12,
> >+	NFPROTO_IPV4,
> >+	NFPROTO_ARP,
> >+	NFPROTO_BRIDGE,
> >+	NFPROTO_IPV6,
> >+	NFPROTO_DECNET,
> > 	NFPROTO_NUMPROTO,
> > };
> 
> This must not be changed under any circumstances. It is exported to
> and used by userspace. (Except perhaps for NFPROTO_DECNET, which
> refers to a quite dead protocol that I think no user parts have ever
> used NFPROTO_DECNET.) I would consider it acceptable to change the
> value for NFPROTO_DECNET if Pablo joins.

If there is some remote posibility to break userspace code, I won't
take the patch, sorry.
