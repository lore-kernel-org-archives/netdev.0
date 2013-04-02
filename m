From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: oops in udpv6_sendmsg
Date: Mon, 01 Apr 2013 18:23:59 -0700
Message-ID: <1364865839.5113.165.camel@edumazet-glaptop>
References: <20130329184006.GA23893@redhat.com>
	 <1364582958.5113.49.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:40660 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757811Ab3DBBYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 21:24:05 -0400
Received: by mail-pa0-f41.google.com with SMTP id kx1so1594563pab.0
        for <netdev@vger.kernel.org>; Mon, 01 Apr 2013 18:24:03 -0700 (PDT)
In-Reply-To: <1364582958.5113.49.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-29 at 11:49 -0700, Eric Dumazet wrote:
> On Fri, 2013-03-29 at 14:40 -0400, Dave Jones wrote:
> > Just hit this on Linus' current tree.
> > 
> > BUG: unable to handle kernel NULL pointer dereference at 0000000000000031
> > IP: [<ffffffff8166ca6b>] udpv6_sendmsg+0x34b/0xa90
> > 
> > Looks like the last line of an inlined __ip6_dst_store() call. So line 1243 of net/ipv6/udp.c
> > 
> > 	Dave
> 
> Yes, I had the same problem on my lab machine yesterday and was working
> on it (Using a linux-3.3.8 code base)
> 
> In my case, the invalid rt6i_node value was 0x66b579de

I am mystified by this problem, I could not reproduce it...

Hmm...
