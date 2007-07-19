From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] ibmveth: Implement ethtool hooks to enable/disable
 checksum offload
Date: Thu, 19 Jul 2007 13:28:26 -0500
Message-ID: <469FAD4A.7090402@linux.vnet.ibm.com>
References: <1184860086366-patch-mail.ibm.com> <200707191548.l6JFmEYM020387@d03av04.boulder.ibm.com> <469F8C80.7070302@indt.org.br> <469FA68F.9070607@linux.vnet.ibm.com> <469FAA9F.9010207@indt.org.br>
Reply-To: brking@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, rcjenn@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Ragner Magalhaes <ragner.magalhaes@indt.org.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:55369 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754981AbXGSS23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 14:28:29 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6JISSkR010360
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 14:28:28 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6JISSKD169262
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 12:28:28 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6JISRgW009060
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 12:28:27 -0600
In-Reply-To: <469FAA9F.9010207@indt.org.br>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ragner Magalhaes wrote:
> ext Brian King wrote:
>> Ragner Magalhaes wrote:
>>> here also, as above ...
>>>> +	if (data && (dev->features & NETIF_F_IP_CSUM))
>>>> +		return 0;
>>>> +	if (!data && !(dev->features & NETIF_F_IP_CSUM))
>>>> +		return 0;
>> This change would make the line > 80 columns, which I prefer to avoid.
>> Updated patch attached which addresses the first comment.
> I think would not be ugly to make.
> 
> 	if ((data && (dev->features & NETIF_F_IP_CSUM)) ||
> 		(!data && !(dev->features & NETIF_F_IP_CSUM)))
> 		return 0;

I find that less readable than what I currently have.

-Brian

-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center
