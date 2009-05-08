From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: interprocess communication with netlinks
Date: Fri, 08 May 2009 11:37:20 +0200
Message-ID: <4A03FD50.7000207@free.fr>
References: <4A0305AE.4000203@free.fr> <765b42e40905072305w39301b38ied44a83a581ad29d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tianjin Zhang <ztianjin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:60378 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345AbZEHJh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 05:37:26 -0400
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate4.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n489bMSe034710
	for <netdev@vger.kernel.org>; Fri, 8 May 2009 09:37:22 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n489bMsW3059790
	for <netdev@vger.kernel.org>; Fri, 8 May 2009 10:37:22 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n489bM8h030589
	for <netdev@vger.kernel.org>; Fri, 8 May 2009 10:37:22 +0100
In-Reply-To: <765b42e40905072305w39301b38ied44a83a581ad29d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tianjin Zhang wrote:
> i think the following  material can help you.
>
> 1. http://lwn.net/Articles/262385/  introduce the IPN,
>
> 2. http://www.linuxjournal.com/article/7356   introduce how to use netlink
> socket and why
>   
Thank you but I already saw these documents. I am used to play with the 
netlink for kernel <-> user communication, I am wondering if it is 
possible to have the applications to communicate, I mean user <-> user.

I saw a comment in the mailing list archive 
http://kerneltrap.org/mailarchive/linux-kernel/2007/12/7/493793/thread

"... with minor adjustments we have the facilities to
meet your needs.  There is no need for yet-another-protocol to do what
you're trying to do, we already have too much duplicated
functionality."


Were these "minor adjustements" done ?

Thanks
  -- Daniel

> On Fri, May 8, 2009 at 12:00 AM, Daniel Lezcano <daniel.lezcano@free.fr>wrote:
>
>   
>> Hi netdev gurus !
>>
>> I am trying to make several processes to communicate via the netlink
>> protocol.
>>
>> I saw a discussion around the AF_IPN (inter process communication) protocol
>> and it seems the same can be done with the AF_NETLINK protocol with minor
>> modifications in the kernel. Were these modifications done ?
>>
>> I am trying to use multicast between several processes, for notification.
>>
>> What protocol should I use to create the socket ?
>>
>>   fd = socket(PF_NETLINK, SOCK_RAW,  ???);
>>
>> I was not able to find any suitable pointer to explain how to do that, so I
>> blindly tried several combinations but I am afraid to interact with the
>> other netlink protocols when using a multicast group, especially when there
>> are other applications like avahi-daemon or "ip monitor all".
>>
>> Does anyone have a pointer to a documentation (not the redhat one, pls), or
>> some clues ?
>>
>> Thanks in advance.
>>  -- Daniel
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>     
>
>   

