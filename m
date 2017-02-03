From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [net-next PATCH 2/5] virtio_net: factor out xdp handler for
 readability
Date: Thu, 2 Feb 2017 17:05:48 -0800
Message-ID: <20170202170548.74c9d1e3@cakuba.netronome.com>
References: <20170202231404.14366.64298.stgit@john-Precision-Tower-5810>
        <20170202232052.14366.25904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, ast@fb.com, mst@redhat.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:18407 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751565AbdBCBGM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 20:06:12 -0500
In-Reply-To: <20170202232052.14366.25904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 02 Feb 2017 15:20:52 -0800, John Fastabend wrote:
> At this point the do_xdp_prog is mostly if/else branches handling
> the different modes of virtio_net. So remove it and handle running
> the program in the per mode handlers.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

I think you rebased away Daniel's tracepoints here :(
