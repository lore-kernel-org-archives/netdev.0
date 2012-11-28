From: =?UTF-8?B?5Y+26Zuo6aOe?= <sunyucong@gmail.com>
Subject: Re: IPv4 route cache DOS attack
Date: Tue, 27 Nov 2012 17:34:09 -0800
Message-ID: <CAJygYd2OETjp+4+uKFM=fiygMXHiSj545TQ8zbiYwzSN7JCF5A@mail.gmail.com>
References: <CAJygYd1OSTfpdbA57q0c6ppMtft3iB7uzo-RCXFOamGp2XVzBg@mail.gmail.com>
 <1354064474.14302.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:37508 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975Ab2K1Bea convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 20:34:30 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so7552939vbb.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 17:34:29 -0800 (PST)
In-Reply-To: <1354064474.14302.44.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks!!! it works, after flushing cache it stays 0.

On Tue, Nov 27, 2012 at 5:01 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Tue, 2012-11-27 at 15:15 -0800, =E5=8F=B6=E9=9B=A8=E9=A3=9E wrote:
>> Hi,
>>
>> I have a linux router running kernel 3.2  that receive public ingres=
s
>> packets and route them through an GRE tunnel, return packets don't g=
o
>> through it
>>
>> I've recently faced a serious issue with the route cache,  when the
>> router received spoofed source , the route cache will quickly get
>> exhausted (depending on the size of it) and soon the ip dst cache
>> overflow will be printed and network subsystem will hang until
>> restarted.
>>
>> So, my question is, how can I turn off the route cache without
>> recompile the kernel or adding the  patch for removal  in 3.7?  I
>> tried to set
>>
>> echo 0 > /proc/sys/net/ipv4/route/max_size but that has no effect at=
 all.
>>
>> And if some one can share some insight on why when dst cache
>> overflows, the network subsystem hangs, it would be great.
>
> echo -1 >/proc/sys/net/ipv4/rt_cache_rebuild_count
>
>
>
