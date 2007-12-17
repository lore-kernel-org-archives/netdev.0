From: Patrick McHardy <kaber@trash.net>
Subject: Re: "ip neigh show" not showing arp cache entries?
Date: Tue, 18 Dec 2007 00:51:36 +0100
Message-ID: <47670B88.4010906@trash.net>
References: <4760279E.1080203@nortel.com>	<47602DD0.8070402@cosmosbay.com> <47605934.2060604@nortel.com> <20071213.070641.20411400.yoshfuji@linux-ipv6.org> <476696A5.1010101@nortel.com> <4766B99D.8060408@trash.net> <4766D261.1020005@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, dada1@cosmosbay.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39161 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761099AbXLQXvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 18:51:38 -0500
In-Reply-To: <4766D261.1020005@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> Patrick McHardy wrote:
> 
>>  From a kernel perspective there are only complete dumps, the
>> filtering is done by iproute. So the fact that it shows them
>> when querying specifically implies there is a bug in the
>> iproute neighbour filter. Does it work if you omit "all"
>> from the ip neigh show command?
> 
> Omitting "all" gives identical results.  It is still missing entries 
> when compared with the output of "arp".


In that case the easiest way to debug this is probably if you
add some debugging to ip/ipneigh.c:print_neigh() since I'm
unable to reproduce this problem. A printf for all the filter
conditions (=> return 0) at the top should do.

