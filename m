From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 1/2] ixgbe: change ndo_xdp_xmit return code on xmit errors
Date: Thu, 17 Aug 2017 11:32:42 -0700
Message-ID: <5995E14A.3000002@gmail.com>
References: <150298692691.6608.11908184719252996949.stgit@firesoul> <150298695248.6608.8521160586255097145.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35378 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdHQScv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 14:32:51 -0400
Received: by mail-pg0-f54.google.com with SMTP id v189so48044136pgd.2
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 11:32:51 -0700 (PDT)
In-Reply-To: <150298695248.6608.8521160586255097145.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 09:22 AM, Jesper Dangaard Brouer wrote:
> Use errno -ENOSPC ("No space left on device") when the XDP xmit
> have no space left on the TX ring buffer, instead of -ENOMEM.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>

Seems like an improvement to me. You could also potentially
distinguish between DMA mapping errors and descriptor overrun
but likely not needed.

Acked-by: John Fastabend <john.fastabend@gmail.com>
