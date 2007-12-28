From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH net-2.6.25] CAN: Fix plain integer definitions in userspace
 header & new CAN version 20071227
Date: Fri, 28 Dec 2007 09:58:15 +0100
Message-ID: <4774BAA7.4040505@hartkopp.net>
References: <477407C1.1050405@hartkopp.net> <20071227.165052.167438890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, urs@isnogud.escape.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:38603 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbXL1I6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 03:58:18 -0500
In-Reply-To: <20071227.165052.167438890.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Oliver Hartkopp <oliver@hartkopp.net>
> Date: Thu, 27 Dec 2007 21:14:57 +0100
>
>   
>> diff -uprN -X net-2.6.25/Documentation/dontdiff net-2.6.25/include/linux/can/bcm.h export/net2625-2007-12-27/include/linux/can/bcm.h
>> --- net-2.6.25/include/linux/can/bcm.h	2007-12-15 19:33:20.000000000 +0100
>> +++ export/net2625-2007-12-27/include/linux/can/bcm.h	2007-12-27 20:35:54.000000000 +0100
>>     
>
> Also, please properly root your patches in the future:
>
> davem@sunset:~/src/GIT/net-2.6.25$ git apply --check --whitespace=error-all diff
> error: net2625-2007-12-27/include/linux/can/bcm.h: No such file or directory
>
>   

I was just testing the patch with 'patch -p1 < ... ' but after your 
error message i recognized why my patch was faulty as the paths had a 
different root depth. Tnx for the hint. Such a mistake will not happen 
again.

Thanks,
Oliver

