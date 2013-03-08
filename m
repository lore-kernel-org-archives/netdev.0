From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Fri, 8 Mar 2013 16:08:31 +0100
Message-ID: <20130308150831.GD28531@order.stressinduktion.org>
References: <20130307214211.GP7941@order.stressinduktion.org> <20130308055718.GA28531@order.stressinduktion.org> <20130308130433.GB28531@order.stressinduktion.org> <1362754386.15793.226.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51494 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299Ab3CHPIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 10:08:32 -0500
Content-Disposition: inline
In-Reply-To: <1362754386.15793.226.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 08, 2013 at 06:53:06AM -0800, Eric Dumazet wrote:
> No matter how you hash, a hacker can easily fill your defrag unit with
> not complete datagrams, so what's the point ?

I want to harden reassembly logic against all fragments being put in
the same hash bucket because of malicious traffic and thus creating
long list traversals in the fragment queue hash table.

I totally agree that fragments should be avoided if possible.

Thanks,

  Hannes
