From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Wed, 21 Dec 2016 22:29:15 -0500 (EST)
Message-ID: <20161221.222915.2248838531091165151.davem@davemloft.net>
References: <20161221.140431.1651188849352763159.davem@davemloft.net>
        <1482356000.2260.13.camel@stressinduktion.org>
        <20161222014019.5szwzj7lu4vbgidq@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39642 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932915AbcLVD3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 22:29:19 -0500
In-Reply-To: <20161222014019.5szwzj7lu4vbgidq@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Wed, 21 Dec 2016 20:40:19 -0500

> On Wed, Dec 21, 2016 at 10:33:20PM +0100, Hannes Frederic Sowa wrote:
> 
>  > > Given all of this, I think the best thing to do is validate the offset
>  > > after the queue walks, which is pretty much what Dave Jones's original
>  > > patch was doing.
>  > 
>  > I think both approaches protect against the bug reasonably well, but
>  > Dave's patch has a bug: we must either call ip6_flush_pending_frames to
>  > clear the socket write queue with the buggy send request.
> 
> I can fix that up and resubmit, or we can go with your approach.
> DaveM ?

Please respin your patch with the fix Dave.
