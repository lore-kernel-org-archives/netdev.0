From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: Re: alloc_skb from huge memory
Date: Fri, 21 Mar 2014 12:06:19 +0530
Message-ID: <CAGZFCEHG60UQLzV=tkVO44aZSZdXCG=xh26aY3r1E6h_wBMNyA@mail.gmail.com>
References: <CAGZFCEHFBbHdc6ju2nh_smA++V4y4e_+LbLeaKVzRQtHwthGAg@mail.gmail.com>
	<1395378886.9114.124.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:33850 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755671AbaCUGgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 02:36:20 -0400
Received: by mail-yk0-f173.google.com with SMTP id 10so5169180ykt.4
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 23:36:19 -0700 (PDT)
In-Reply-To: <1395378886.9114.124.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2014 at 10:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-03-21 at 10:21 +0530, ratheesh kannoth wrote:
>> alloc_skb  does allocation from slub.   memory  slab could be
>> kmalloc_1024 or kmalloc_512  (  And there is no  skb slab. i could not
>> find in  /proc/slabinfo ).
>>
>> Is there any way  to allocate  skb from huge memory or    pre allocated pages ?
>
> What would be the usage ?
>
> In the kernel, almost all memory is mapped to huge pages anyway.
>
> $ tail -3 /proc/meminfo
> DirectMap4k:        4096 kB
> DirectMap2M:     2084864 kB
> DirectMap1G:    266338304 kB
>

my bad. it is huge pages( what i meant is huge pages; not huge memory ).

I would like to mmap  and use.
