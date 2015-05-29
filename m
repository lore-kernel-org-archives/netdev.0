From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/4] netfilter: default CONFIG_NETFILTER_INGRESS to y
Date: Fri, 29 May 2015 11:44:23 +0200
Message-ID: <20150529094423.GA3347@salvia>
References: <1432856695-23831-1-git-send-email-pablo@netfilter.org>
 <1432856695-23831-3-git-send-email-pablo@netfilter.org>
 <alpine.LSU.2.20.1505290813001.6979@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.20.1505290813001.6979@nerf40.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 29, 2015 at 08:19:35AM +0200, Jan Engelhardt wrote:
> On Friday 2015-05-29 01:44, Pablo Neira Ayuso wrote:
> 
> >Useful to compile-test all options.
> >
> >--- a/net/netfilter/Kconfig
> >+++ b/net/netfilter/Kconfig
> >@@ -3,6 +3,7 @@ menu "Core Netfilter Configuration"
> > 
> > config NETFILTER_INGRESS
> > 	bool "Netfilter ingress support"
> >+	default y
> > 	select NET_INGRESS
> > 	help
> > 	  This allows you to classify packets from ingress using the Netfilter
> 
> Careful with default y. I seem to remember that someone higher up
> (perhaps Linus himself) was against "default y" for features deemed
> not essential (especially hardware drivers), as no driver is any
> more important than another. If "compile-test" is your reason for the
> patch, it might fall into the same category.

This config option is hiding behind the global CONFIG_NETFILTER switch
that, if enabled, gets the very basic hook infrastructure, and this
ingress hook falls into that category.

I agree this makes sense for hardware drivers, but this is not the
case.
