From: Patrick McHardy <kaber@trash.net>
Subject: Re: Funny Routing change since 2.6.16.x
Date: Thu, 08 Feb 2007 17:32:24 +0100
Message-ID: <45CB5098.3020107@trash.net>
References: <200702071756.34409.netdev@axxeo.de> <200702071816.28235.netdev@axxeo.de> <45CA09F2.6050700@trash.net> <200702081652.31527.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44957 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423129AbXBHQc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 11:32:27 -0500
In-Reply-To: <200702081652.31527.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> Patrick McHardy schrieb:
> 
>>Since these packets already have the proper source address chosen
>>by routing, there is no need to NAT them anymore. So the easiest
>>fix is to exclude them manually from masquerading based on the
>>address.
> 
> 
> Just did that (iptables -t nat -I POSTROUTING -s $SRCADDR -o ppp0 -j ACCEPT)
> and it works without any problems.
> 
> Many thanks for your very fast help! I'm very happy now :-)
> 
> Do you know any good place, where this can be documented?


We have a netfilter Wiki now at wiki.netfilter.org. You could add
the first entry :)
