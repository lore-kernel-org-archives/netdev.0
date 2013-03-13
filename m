From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Wed, 13 Mar 2013 02:31:01 +0100
Message-ID: <20130313013101.GF14801@order.stressinduktion.org>
References: <20130307214211.GP7941@order.stressinduktion.org> <20130308055718.GA28531@order.stressinduktion.org> <20130308130433.GB28531@order.stressinduktion.org> <1362754386.15793.226.camel@edumazet-glaptop> <20130308150831.GD28531@order.stressinduktion.org> <1362756219.15793.240.camel@edumazet-glaptop> <20130313012715.GE14801@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60166 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755470Ab3CMBbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 21:31:02 -0400
Content-Disposition: inline
In-Reply-To: <20130313012715.GE14801@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 02:27:15AM +0100, Hannes Frederic Sowa wrote:
> Disable netfilter defragmenation for ipv6 on your machine if you test
> this patch, otherwise you won't see the improvment. Machine now runs
> smoothly under fragmentation dos.

Just to clarify:

When I wrote dos above, I actually meant a dos where the addresses have a
common ipv6_addr_hash. A simple test tool I wrote for testing is here:

  https://gist.github.com/hannes/5116331
