From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 0/5] XDP for virtio_net
Date: Fri, 18 Nov 2016 11:06:57 -0800
Message-ID: <582F5151.3050702@gmail.com>
References: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, brouer@redhat.com
To: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32992 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751989AbcKRTHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 14:07:14 -0500
Received: by mail-pg0-f68.google.com with SMTP id 3so21375852pgd.0
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 11:07:14 -0800 (PST)
In-Reply-To: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-18 10:59 AM, John Fastabend wrote:
> This implements virtio_net for the mergeable buffers and big_packet
> modes. I tested this with vhost_net running on qemu and did not see
> any issues.
> 
> There are some restrictions for XDP to be enabled (see patch 3) for
> more details.
> 
>   1. LRO must be off
>   2. MTU must be less than PAGE_SIZE
>   3. queues must be available to dedicate to XDP
>   4. num_bufs received in mergeable buffers must be 1
>   5. big_packet mode must have all data on single page
> 
> Please review any comments/feedback welcome as always.
> 
> Thanks,
> John
> ---
> 

Hi Dave,

Should be obvious but this is for net-next I dropped the tag from my
git-send command.

Also I missed probably the most important person on the CC/TO list.

+Michael Tsirkin.

Thanks,
John
