From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rps: memory leak due to forget to release rx queues
Date: Tue, 23 Mar 2010 15:02:49 +0800
Message-ID: <412e6f7f1003230002y3275cd3ak53b86b7acfe553d0@mail.gmail.com>
References: <4BA85A33.6050004@gmail.com> <65634d661003222344s662000e8ode1b4f49ff73b345@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:42521 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641Ab0CWHDJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 03:03:09 -0400
Received: by iwn6 with SMTP id 6so1474957iwn.4
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 00:03:09 -0700 (PDT)
In-Reply-To: <65634d661003222344s662000e8ode1b4f49ff73b345@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 23, 2010 at 2:44 PM, Tom Herbert <therbert@google.com> wrot=
e:
> 2010/3/22 Changli Gao <xiaosuo@gmail.com>:
>> memory leak due to forget to release rx queues.
>>
>> rx queues is allocated in alloc_netdev_mq(), but they aren't release=
d in
>> free_netdev(), and the field rps_map is also miss.
>>

Thanks for explaining.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
