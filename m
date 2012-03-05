From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v9 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Mon, 5 Mar 2012 17:50:24 +0100
Message-ID: <20120305165024.GA28940@1984>
References: <1329387672-23683-1-git-send-email-hans.schillstrom@ericsson.com>
 <1329387672-23683-3-git-send-email-hans.schillstrom@ericsson.com>
 <20120304184459.GA24338@1984>
 <201203051109.48817.hans.schillstrom@ericsson.com>
 <alpine.LNX.2.01.1203051140470.19304@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1203051140470.19304@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2012 at 11:48:16AM +0100, Jan Engelhardt wrote:
> 
> On Monday 2012-03-05 11:09, Hans Schillstrom wrote:
> >> > diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> >> > index 40f4c3d..21bc5e8 100644
> >> > --- a/net/netfilter/Makefile
> >> > +++ b/net/netfilter/Makefile
> >> > @@ -57,6 +57,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
> >> >  obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
> >> >  obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
> >> >  obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
> >> > +obj-$(CONFIG_NETFILTER_XT_TARGET_HMARK) += xt_hmark.o
> >> 
> >> Netfilter's naming policy requires that targets are in upper case.
> >
> >I asked netfilter team about that, and got the answer
> >that it should be lower case for new modules.
> >Have that been changed ?
> 
> The name of the file is pretty much irrelevant (because loading
> solely depends on MODULE_ALIAS), so I share that only lowercase
> should be used for new things. It's not that the linux kernel would
> currently be storable on a case-insensitive filesystem, but that does
> not mean we can't latently work towards it.

Sorry, I want to stick to that naming policy.
