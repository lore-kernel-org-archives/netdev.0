From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: alloc_skb from huge memory
Date: Thu, 20 Mar 2014 22:14:46 -0700
Message-ID: <1395378886.9114.124.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAGZFCEHFBbHdc6ju2nh_smA++V4y4e_+LbLeaKVzRQtHwthGAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:51078 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbaCUFOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 01:14:49 -0400
Received: by mail-pb0-f41.google.com with SMTP id jt11so1936435pbb.14
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 22:14:49 -0700 (PDT)
In-Reply-To: <CAGZFCEHFBbHdc6ju2nh_smA++V4y4e_+LbLeaKVzRQtHwthGAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-21 at 10:21 +0530, ratheesh kannoth wrote:
> alloc_skb  does allocation from slub.   memory  slab could be
> kmalloc_1024 or kmalloc_512  (  And there is no  skb slab. i could not
> find in  /proc/slabinfo ).
> 
> Is there any way  to allocate  skb from huge memory or    pre allocated pages ?

What would be the usage ?

In the kernel, almost all memory is mapped to huge pages anyway.

$ tail -3 /proc/meminfo 
DirectMap4k:        4096 kB
DirectMap2M:     2084864 kB
DirectMap1G:    266338304 kB
