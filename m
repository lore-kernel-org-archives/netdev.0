From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH net-2.6.25] CAN: Fix plain integer definitions in userspace
 header & new CAN version 20071227
Date: Fri, 28 Dec 2007 10:26:39 +0100
Message-ID: <4774C14F.9010809@hartkopp.net>
References: <477407C1.1050405@hartkopp.net> <20071227.164900.233018217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, urs@isnogud.escape.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:48386 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbXL1J0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 04:26:41 -0500
In-Reply-To: <20071227.164900.233018217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Oliver Hartkopp <oliver@hartkopp.net>
> Date: Thu, 27 Dec 2007 21:14:57 +0100
>
>   
>> This patch fixes the use of plain integers instead of __u32 in a struct 
>> that is visible from kernel space and user space. As this change is user 
>> visible this patch also updates the CAN version to 20071227.
>>
>> Thanks to Sam Ravnborg for pointing out the wrong plain int usage.
>>
>> It applies on the current net-2.6.25 tree.
>>     
>
> The types are exactly the same size regardless of anything.
>
> There is no reason to make such a big fuss about this, changing the
> CAN version etc.
>
> Also, since CAN has never shown up in a released kernel, there is
> nothing to be incompatible with.
>   

The CAN stuff is also available in the 'SocketCAN' SVN for older 2.6 
Kernels and i backported the latest code to Kernel 2.4 two weeks ago as 
some people still use it. As a change in bcm.h is user visable i just 
wanted to freeze the latest version of the header files into a 
consistent CAN version for Mainline, older 2.6 and 2.4 Kernels. That was 
the reason for creating version 20071227 *before* it hits a released Kernel.

Thanks
Oliver

