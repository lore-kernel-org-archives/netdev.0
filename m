From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
 prior to interface-up
Date: Mon, 14 Apr 2008 07:57:31 +0200
Message-ID: <4802F24B.7060104@trash.net>
References: <20080414060114.GA4016@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, pebolle@tiscali.nl,
	netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	jgarzik@redhat.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62401 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbYDNGAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:00:46 -0400
In-Reply-To: <20080414060114.GA4016@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On 14-04-2008 07:44, David Miller wrote:
>   
>> From: Paul Bolle <pebolle@tiscali.nl>
>> Date: Thu, 10 Apr 2008 17:00:17 +0200
>>
>>     
>>> From: Paul Bolle <pebolle@tiscali.nl>
>>>    
>>> Commit bada339 (Validate device addr prior to interface-up) caused a regression
>>> in the ISDN network code, see: http://bugzilla.kernel.org/show_bug.cgi?id=9923
>>> The trivial fix is to remove the pointer to eth_validate_addr() in the
>>> net_device struct in isdn_net_init().
>>>     
>>> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
>>>       
>> Applied, thanks a lot Paul.
>>     
>
> Maybe I missed Patrick point, but it seems this patch isn't good:
> it omits address validation hiding possible problems.
The ISDN device's address is computed from the IP addresses
in ->open(), so there is nothing to validate at the time
eth_validate_addr() is called.


