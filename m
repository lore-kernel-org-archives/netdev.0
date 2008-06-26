From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: (usagi-users 04056) Re: ping6 is sent out from wrong interface
Date: Thu, 26 Jun 2008 09:48:26 +0900
Message-ID: <4862E75A.8060006@miraclelinux.com>
References: <4861ED72.6080100@miraclelinux.com> <69A5E767EC979846826F566C7932A3F207233B5F@exchange03.iabg.de> <48621B7E.5090600@miraclelinux.com> <69A5E767EC979846826F566C7932A3F207233D99@exchange03.iabg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: usagi-users@ml.linux-ipv6.org,
	=?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2k=?=
	 =?ISO-2022-JP?B?IC8gGyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
	usagi-users@linux-ipv6.org
To: Fey Marcus <Fey@iabg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:14485 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbYFZAs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 20:48:28 -0400
In-Reply-To: <69A5E767EC979846826F566C7932A3F207233D99@exchange03.iabg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcus

Thank you for your comment.

>>
>> Thank you for your quick reply.
>>
>>> It's due to routing.
>> For the reason of selecting 'eth0', I agree.
>> But, I think the device is specified before looking up the 
>> routing table in this case.
> 
> Well, ping's man page reads: 
> ---
>        -I interface address
>               Set source address to specified interface  address.  Argument
>               may  be  numeric  IP  address or name of device. When pinging
>               IPv6 link-local address this option is required.
> ---
> 
> So you only set the address, not the interface to be used for sending.

Then, the man page doesn't match with the implementation.

> 
>>> ...with eth0 being preferred over eth1 for multicast packets.
>>> You could add a dedicated route for ff02::/16 to make the 
>> kernel output the packet via eth1.
>>
>> This works when using only "eth1" for multicasts.
>> When multiple I/Fs are connected to separate networks, this 
>> scheme requires changing the route every time a user need to 
>> send ping to different network.
>>
> 
> Ok, my proposition was a bit too general. It would probably be better to set up routes for the exact addresses. So in your case to ff02::1. 
> 
> Of course, if you wish to send the same packet via several interfaces within a short time, this would still result in adding and deleting the routes over and over again.
> 
>> I think kernel can solve this problem better.
>>
> 
> I don't think this would be intended....
> 

I was just confused by the difference of
source address things between IPv4 and IPv6.

Regards,
Naohiro Ooiwa


