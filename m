From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/2] rx zero copy interface for af_packet
Date: Mon, 30 Jan 2017 17:02:26 -0500 (EST)
Message-ID: <20170130.170226.538329603326381961.davem@davemloft.net>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn.topel@gmail.com, jasowang@redhat.com, ast@fb.com,
        alexander.duyck@gmail.com, brouer@redhat.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42592 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752115AbdA3WC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 17:02:28 -0500
In-Reply-To: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 27 Jan 2017 13:33:20 -0800

> This is an experimental implementation of rx zero copy for af_packet.
> Its a bit rough and likely has errors but the plan is to clean it up
> over the next few months.
> 
> And seeing I said I would post it in another thread a few days back
> here it is.
> 
> Comments welcome and use at your own risk.

The one thing I do like about this is the fact that the user cannot
access the DMA length and DMA address in the hardware descriptors.

So, at least in that sense, the kernel is still providing the
necessary protection between the user and the hardware device.
