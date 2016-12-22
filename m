From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Wed, 21 Dec 2016 20:40:19 -0500
Message-ID: <20161222014019.5szwzj7lu4vbgidq@codemonkey.org.uk>
References: <CAM_iQpXWCWMKDjLVTLuHNSKKGq5MWf5ZRLpyE=PDD3EgQ7PS4Q@mail.gmail.com>
 <1482323232.2260.2.camel@stressinduktion.org>
 <1482324073.2260.4.camel@stressinduktion.org>
 <20161221.140431.1651188849352763159.davem@davemloft.net>
 <1482356000.2260.13.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:36086 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932368AbcLVBk0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 20:40:26 -0500
Content-Disposition: inline
In-Reply-To: <1482356000.2260.13.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 10:33:20PM +0100, Hannes Frederic Sowa wrote:

 > > Given all of this, I think the best thing to do is validate the offset
 > > after the queue walks, which is pretty much what Dave Jones's original
 > > patch was doing.
 > 
 > I think both approaches protect against the bug reasonably well, but
 > Dave's patch has a bug: we must either call ip6_flush_pending_frames to
 > clear the socket write queue with the buggy send request.

I can fix that up and resubmit, or we can go with your approach.
DaveM ?

	Dave
