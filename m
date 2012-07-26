From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 19:30:58 +0200
Message-ID: <1343323858.2626.11783.camel@edumazet-glaptop>
References: <1343290414.2626.11181.camel@edumazet-glaptop>
	 <20120726.011853.973075299731735416.davem@davemloft.net>
	 <1343291278.2626.11188.camel@edumazet-glaptop>
	 <20120726.014736.1066206957795563053.davem@davemloft.net>
	 <CAKgT0UfYEBYQOAoZ77rtwctbwau=2kx4rYdTyeaPaipeMUP9aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37393 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670Ab2GZRbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 13:31:04 -0400
Received: by bkwj10 with SMTP id j10so1424165bkw.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 10:31:03 -0700 (PDT)
In-Reply-To: <CAKgT0UfYEBYQOAoZ77rtwctbwau=2kx4rYdTyeaPaipeMUP9aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-26 at 10:18 -0700, Alexander Duyck wrote:

> I tested this patch and it looks like it runs, but still has the same
> performance issue.  I did some digging into the annotation for
> ip_route_intput_noref and it seems like the issue is that I am hitting
> the dst_hold call in  __mkroute_input.

David suggested a percpu cache.

nh_rth_input would be allocated by alloc_percpu(struct dst *)

I can work on this.
