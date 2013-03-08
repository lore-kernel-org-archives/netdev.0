From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash
 table
Date: Fri, 08 Mar 2013 06:53:06 -0800
Message-ID: <1362754386.15793.226.camel@edumazet-glaptop>
References: <20130307214211.GP7941@order.stressinduktion.org>
	 <20130308055718.GA28531@order.stressinduktion.org>
	 <20130308130433.GB28531@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:48463 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757848Ab3CHOxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 09:53:10 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so1354499pad.10
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 06:53:09 -0800 (PST)
In-Reply-To: <20130308130433.GB28531@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-08 at 14:04 +0100, Hannes Frederic Sowa wrote:

> Ok if I send a patch later to revert this change? What do you think about
> increasing the size of the fragmentation queue hash table INETFRAGS_HASHSZ,
> too?

Thats because reassembly hash was so small, and number of in flight
reassembly is so small anyway, that I felt not worth having so many
instructions to compute a hash that is truncated to 6 bits

In real life I always advocate _not_ using fragments, I dont know why so
many people try to used them.

No matter how you hash, a hacker can easily fill your defrag unit with
not complete datagrams, so what's the point ?
