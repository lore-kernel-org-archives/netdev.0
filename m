From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: interprocess communication with netlinks
Date: Mon, 11 May 2009 12:36:43 -0700
Message-ID: <4A087E4B.4000602@oracle.com>
References: <4A0305AE.4000203@free.fr> <765b42e40905072305w39301b38ied44a83a581ad29d@mail.gmail.com> <4A03FD50.7000207@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tianjin Zhang <ztianjin@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:58545 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757360AbZEKTet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 15:34:49 -0400
In-Reply-To: <4A03FD50.7000207@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Tianjin Zhang wrote:
>> i think the following  material can help you.
>>
>> 1. http://lwn.net/Articles/262385/  introduce the IPN,
>>
>> 2. http://www.linuxjournal.com/article/7356   introduce how to use
>> netlink
>> socket and why
>>   
> Thank you but I already saw these documents. I am used to play with the
> netlink for kernel <-> user communication, I am wondering if it is
> possible to have the applications to communicate, I mean user <-> user.
> 
> I saw a comment in the mailing list archive
> http://kerneltrap.org/mailarchive/linux-kernel/2007/12/7/493793/thread
> 
> "... with minor adjustments we have the facilities to
> meet your needs.  There is no need for yet-another-protocol to do what
> you're trying to do, we already have too much duplicated
> functionality."
> 
> 
> Were these "minor adjustements" done ?
> 
> Thanks
>  -- Daniel
> 
>> On Fri, May 8, 2009 at 12:00 AM, Daniel Lezcano
>> <daniel.lezcano@free.fr>wrote:
>>
>>  
>>> Hi netdev gurus !
>>>
>>> I am trying to make several processes to communicate via the netlink
>>> protocol.
>>>
>>> I saw a discussion around the AF_IPN (inter process communication)
>>> protocol
>>> and it seems the same can be done with the AF_NETLINK protocol with
>>> minor
>>> modifications in the kernel. Were these modifications done ?
>>>
>>> I am trying to use multicast between several processes, for
>>> notification.
>>>
>>> What protocol should I use to create the socket ?
>>>
>>>   fd = socket(PF_NETLINK, SOCK_RAW,  ???);
>>>
>>> I was not able to find any suitable pointer to explain how to do
>>> that, so I
>>> blindly tried several combinations but I am afraid to interact with the
>>> other netlink protocols when using a multicast group, especially when
>>> there
>>> are other applications like avahi-daemon or "ip monitor all".
>>>
>>> Does anyone have a pointer to a documentation (not the redhat one,
>>> pls), or
>>> some clues ?

There's also a paper/doc here:
  http://people.redhat.com/nhorman/papers/netlink.pdf

-- 
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
