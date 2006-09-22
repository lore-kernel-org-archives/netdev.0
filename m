From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] [Bugme-new] [Bug 7179] New: Compilation of .tmp_linux1 fails due to missing declaration in net/netfilter/xt_physdev.c
Date: Fri, 22 Sep 2006 12:51:22 +0200
Message-ID: <20060922105122.GA12425@ff.dom.local>
References: <20060921153701.2c49e331.akpm@osdl.org> <20060922084108.GB6820@ff.dom.local> <20060922092731.GC6820@ff.dom.local> <20060922095556.GA11991@ff.dom.local> <4513B7CF.5040209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"David S\. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:30948 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S932134AbWIVKrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 06:47:15 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4513B7CF.5040209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2006 at 12:15:43PM +0200, Patrick McHardy wrote:
...
> We should fix the physdev dependencies since this is what is causing
> problems.
...
>  config NETFILTER_XT_MATCH_PHYSDEV
>  	tristate '"physdev" match support'
> -	depends on NETFILTER_XTABLES && BRIDGE_NETFILTER
> +	depends on NETFILTER_XTABLES && BRIDGE && BRIDGE_NETFILTER

Sure! But someone may ask what for BRIDGE_NETFILTER depends
on BRIDGE if you should repeat this? 

Jarek P.
