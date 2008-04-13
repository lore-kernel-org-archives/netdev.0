From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
   prior to interface-up
Date: Sun, 13 Apr 2008 10:05:08 +0200
Message-ID: <4801BEB4.6090909@trash.net>
References: <1207839617.4311.6.camel@compaq.thuisdomein> <4801A85F.8090906@trash.net> <4801BF1C.30207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, Jeff Garzik <jgarzik@redhat.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36554 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbYDMIId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 04:08:33 -0400
In-Reply-To: <4801BF1C.30207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Patrick McHardy wrote, On 04/13/2008 08:29 AM:
> ...
>
>   
>> I guess it should return -EADDRNOTAVAIL similar to eth_mac_addr()
>> when validation fails.
>>     
>
> I think an additional printk should really save some time in guessing
> what's wrong and with which address, especially if the same config
> works OK with earlier kernels.
>   

In my opinion a proper error code like EADDRNOTAVAIL is enough, we
have thousands of checks that might make things fail, should we
add a printk to every one of those?


