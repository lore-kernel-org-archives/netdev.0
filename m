From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 3 Sep 2008 09:56:25 +0200
Message-ID: <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com>
References: <7e0dd21a0809021127n35cd38d7m98be5ee5d7158788@mail.gmail.com>
	 <20080902194603.GA2825@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:34263 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbYICH40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 03:56:26 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2650628rvb.1
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2008 00:56:25 -0700 (PDT)
In-Reply-To: <20080902194603.GA2825@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

>> I've made lot of tests, playing with jumbo frames, raw sockets, ...
>> I've never exceeded ~25Mbytes/s. So I've decided to analyze deeply the
>> packet socket transmission process.
>>
>> The main blocking point was the memcpy_fromiovec() function that is
>> located in the packet_sendmsg() of af_packet.c.
>
> Can you saturate the link with usual tcp/udp socket?

No, only ~15-20Mo/s with standard tcp/udp socket.

>
>> But, I would like to get as much criticism as possible in order to
>> start a discussion with experts about a conceivable way to mix
>> zero-copy, sk_buff management and packet socket.
>> Which is perhaps impossible with current network kernel flow ...
>
> Did you try vmsplice and splice?
> It is the preferred way to do a zero-copy.

Not yet, I will perform some tests using splice and let you know performances.

Many thanks,
Johann



-- 
Johann Baudy
johaahn@gmail.com
