From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [XFRM]: xfrm_user: fix selector family initialization
Date: Thu, 10 Apr 2008 09:11:08 +0900
Message-ID: <47FD5B1C.3060005@miyazawa.org>
References: <47F4EB73.1040705@trash.net>	<47FBC2AF.7050508@trash.net>	<47FCE30F.8060400@trash.net> <20080409.150931.93235087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, pupilla@hotmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:33753 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753641AbYDJALy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 20:11:54 -0400
In-Reply-To: <20080409.150931.93235087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 09 Apr 2008 17:38:55 +0200
> 
>>     [XFRM]: xfrm_user: fix selector family initialization
>>     
>>     Commit df9dcb45 ([IPSEC]: Fix inter address family IPsec tunnel handling)
>>     broke openswan by removing the selector initialization for tunnel mode
>>     in case it is uninitialized.
>>     
>>     This patch restores the initialization, fixing openswan, but probably
>>     breaking inter-family tunnels again (unknown since the patch author
>>     disappeared). The correct thing for inter-family tunnels is probably
>>     to simply initialize the selector family explicitly.
>>     
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> I've applied this to net-2.6, thanks Patrick.
> 
> Once we resolve how to get inter-family working without
> breaking existing setups, we can put better logic back
> in here.  But for now the regression is more important.

Sorry, I missed the thread.
I have no idea to solve the regression.
Thank you Patrick,

--
Kazunori Miyazawa
