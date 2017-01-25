From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v3 net] ravb: unmap descriptors when freeing rings
Date: Wed, 25 Jan 2017 19:18:15 +0300
Message-ID: <312867f0-f6dd-3c92-df09-fae72ea7405b@cogentembedded.com>
References: <1485282073-16662-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:33028 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751008AbdAYQST (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 11:18:19 -0500
Received: by mail-lf0-f49.google.com with SMTP id x1so44889016lff.0
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 08:18:19 -0800 (PST)
In-Reply-To: <1485282073-16662-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2017 09:21 PM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> "swiotlb buffer is full" errors occur after repeated initialisation of a
> device - f.e. suspend/resume or ip link set up/down. This is because memory
> mapped using dma_map_single() in ravb_ring_format() and ravb_start_xmit()
> is not released.  Resolve this problem by unmapping descriptors when
> freeing rings.

    Could you look into the sh_eth driver which seems to have the same issue?

> Note, ravb_tx_free() is moved but not otherwise modified by this patch.

    This is not true anymore BTW.

> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> [simon: reworked]
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

MBR, Sergei
