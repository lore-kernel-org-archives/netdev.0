From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Blogpost evaluation this [PATCH v4 net-next RFC] net: Generic XDP
Date: Mon, 24 Apr 2017 16:24:05 +0200
Message-ID: <20170424162405.1183f2e7@redhat.com>
References: <20170413.120925.2082322246776478766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com,
        Andy Gospodarek <andy@greyhouse.net>
To: David Miller <davem@davemloft.net>, xdp-newbies@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57852 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764064AbdDXOYM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 10:24:12 -0400
In-Reply-To: <20170413.120925.2082322246776478766.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've done a very detailed evaluation of this patch, and I've created a
blogpost like report here:

 https://prototype-kernel.readthedocs.io/en/latest/blogposts/xdp25_eval_generic_xdp_tx.html

I didn't evaluate the adjust_head part, so I hope Andy is still
planning to validate that part?

--Jesper



On Thu, 13 Apr 2017 12:09:25 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> This provides a generic SKB based non-optimized XDP path which is used
> if either the driver lacks a specific XDP implementation, or the user
> requests it via a new IFLA_XDP_FLAGS value named XDP_FLAGS_SKB_MODE.
> 
> It is arguable that perhaps I should have required something like
> this as part of the initial XDP feature merge.
> 
> I believe this is critical for two reasons:
> 
> 1) Accessibility.  More people can play with XDP with less
>    dependencies.  Yes I know we have XDP support in virtio_net, but
>    that just creates another depedency for learning how to use this
>    facility.
> 
>    I wrote this to make life easier for the XDP newbies.
> 
> 2) As a model for what the expected semantics are.  If there is a pure
>    generic core implementation, it serves as a semantic example for
>    driver folks adding XDP support.
> 
> This is just a rough draft and is untested.



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
