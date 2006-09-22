From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [Bugme-new] [Bug 7179] New: Compilation of .tmp_linux1
 fails due to missing declaration in net/netfilter/xt_physdev.c
Date: Fri, 22 Sep 2006 12:54:42 +0200
Message-ID: <4513C0F2.1030107@trash.net>
References: <20060921153701.2c49e331.akpm@osdl.org> <20060922084108.GB6820@ff.dom.local> <20060922092731.GC6820@ff.dom.local> <20060922095556.GA11991@ff.dom.local> <4513B7CF.5040209@trash.net> <20060922105122.GA12425@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:29180 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932172AbWIVKyp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 06:54:45 -0400
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20060922105122.GA12425@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Fri, Sep 22, 2006 at 12:15:43PM +0200, Patrick McHardy wrote:
> ...
> 
>>We should fix the physdev dependencies since this is what is causing
>>problems.
> 
> ...
> 
>> config NETFILTER_XT_MATCH_PHYSDEV
>> 	tristate '"physdev" match support'
>>-	depends on NETFILTER_XTABLES && BRIDGE_NETFILTER
>>+	depends on NETFILTER_XTABLES && BRIDGE && BRIDGE_NETFILTER
> 
> 
> Sure! But someone may ask what for BRIDGE_NETFILTER depends
> on BRIDGE if you should repeat this? 

Simply because it really depends on BRIDGE. The reason why we need
BRIDGE as dependency here also is because BRIDGE_NETFILTER is a
boolean, but may still result in a module because of special
logic in the bridge makefile.


