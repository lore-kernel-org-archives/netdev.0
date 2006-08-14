From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Mon, 14 Aug 2006 10:46:17 -0700
Message-ID: <44E0B6E9.8050608@hp.com>
References: <20060814110359.GA27704@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:6854 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S932333AbWHNRqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 13:46:19 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060814110359.GA27704@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Benchmarks with trivial epoll based web server showed noticeble (more
> than 40%) imrovements of the request rates (1600-1800 requests per
> second vs. more than 2300 ones). It can be described by more
> cache-friendly freeing algorithm, by tighter objects packing and thus
> reduced cache line ping-pongs, reduced lookups into higher-layer caches
> and so on.

Is that an hypothesis, or did you get a chance to gather cache stats 
with something like http://www.hp.com/go/Caliper or the like on the 
platform(s) you were testing?

rick jones

