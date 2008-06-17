From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH,RFC] skb->network_header and __vlan_put_tag()
Date: Tue, 17 Jun 2008 14:19:38 +0200
Message-ID: <4857ABDA.6050407@trash.net>
References: <20080616221525.GG27971@xi.wantstofly.org> <m3prqgpe1e.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62456 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755352AbYFQMTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 08:19:43 -0400
In-Reply-To: <m3prqgpe1e.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Don't trim CC lists please]

Benny Amorsen wrote:
> Lennert Buytenhek <buytenh@wantstofly.org> writes:
> 
>> I'm adding VLAN support to mv643xx_eth (which does not support HW
>> insertion of a VLAN tag, but it does support HW checksumming when
>> a VLAN tag is present, you just have to tell the HW how many bytes
>> there are between the start of the packet and the IP header), and
>> I'm ending up with code like this:
>>
>> 	if (skb->protocol == htons(ETH_P_8021Q))
>> 		ip_header = ip_hdr(skb) + 4;
>> 	else
>> 		ip_header = ip_hdr(skb);
> 
> How well does this work when doing QinQ or QinQinQ?

Currently probably doesn't work, so the patch makes even more
sense.
