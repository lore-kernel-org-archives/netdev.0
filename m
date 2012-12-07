From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] dynamic_queue_limit.h: Make the struct
 ___cacheline_aligned_on_smp
Date: Fri, 07 Dec 2012 08:19:04 -0800
Message-ID: <1354897144.26405.4.camel@edumazet-glaptop>
References: <1354892334.29937.14.camel@joe-AO722>
	 <CAL4Wiip12_Frb64WGk419_YApOuckTa3Jtd-nVROodLFTqvacg@mail.gmail.com>
	 <1354896346.29937.43.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34485 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422667Ab2LGQTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 11:19:09 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so461103pbc.19
        for <netdev@vger.kernel.org>; Fri, 07 Dec 2012 08:19:08 -0800 (PST)
In-Reply-To: <1354896346.29937.43.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-07 at 08:05 -0800, Joe Perches wrote:

> So it seemed somewhat sensible to make the
> entire struct in a single cacheline.

Any layout change in an object used in network fast path need a complete
performance study.

Even if you provide such a study, we'll need to reproduce your numbers
here.

BQL/DQL is not on our radars, spending two cache lines on a critical
object is fine.

Thanks
