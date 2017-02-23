From: David Miller <davem@redhat.com>
Subject: Re: netvsc NAPI
Date: Thu, 23 Feb 2017 18:24:06 -0500 (EST)
Message-ID: <20170223.182406.911130671484909443.davem@redhat.com>
References: <20170222093316.303203c3@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751318AbdBWXYI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 18:24:08 -0500
In-Reply-To: <20170222093316.303203c3@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 22 Feb 2017 09:33:16 -0800

> NAPI for netvsc is ready but the merge coordination is a nuisance.
> 
> Since netvsc NAPI support requires other changes that are proceeding through
> GregKH's char-misc tree. I would like to send the two patches after current net-next
> and char-misc-next are merged into Linus's tree.
> 
> Need these (at a minimum) these changes
> 
>  6e47dd3e2938 ("vmbus: expose hv_begin/end_read")
>  5529eaf6e79a ("vmbus: remove conditional locking of vmbus_write")
>  b71e328297a3 ("vmbus: add direct isr callback mode")
>  631e63a9f346 ("vmbus: change to per channel tasklet")
>  37cdd991fac8 ("vmbus: put related per-cpu variable together")
> 
> Please let me know when linux-net is up to date with these.

The 'net' tree is now current with Linus's current tree, and all of
those above commits seem to be there.
