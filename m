From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH] b44: add 64 bit stats
Date: Sun, 15 Jul 2012 13:51:12 -0400
Message-ID: <CABF+-6VZB=V1j2cAzhNkJozvcVs=VrQGYX_71HiZJ+g6od7qyA@mail.gmail.com>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
	<1342337165.3265.10640.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:47200 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807Ab2GORvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 13:51:13 -0400
Received: by vcbfk26 with SMTP id fk26so459957vcb.19
        for <netdev@vger.kernel.org>; Sun, 15 Jul 2012 10:51:12 -0700 (PDT)
In-Reply-To: <1342337165.3265.10640.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for the feedback on my patch.

On Sun, Jul 15, 2012 at 3:26 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> b44_stats_update() is run from timer, (softirq), check b44_timer()

Yes, I knew that.  b44_stats_update() is also called from
b44_get_ethtool_stats().

> So you must use u64_stats_fetch_begin_bh()

That I did not know, although it makes sense after I read more about
it.  I will submit a new patch with this fixed.


Kevin
