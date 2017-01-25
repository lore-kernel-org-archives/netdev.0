From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC v3 net] ravb: unmap descriptors when freeing rings
Date: Wed, 25 Jan 2017 17:48:57 +0100
Message-ID: <20170125164857.GD12042@verge.net.au>
References: <1485282073-16662-1-git-send-email-horms+renesas@verge.net.au>
 <312867f0-f6dd-3c92-df09-fae72ea7405b@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36060 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbdAYQtD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 11:49:03 -0500
Content-Disposition: inline
In-Reply-To: <312867f0-f6dd-3c92-df09-fae72ea7405b@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 07:18:15PM +0300, Sergei Shtylyov wrote:
> On 01/24/2017 09:21 PM, Simon Horman wrote:
> 
> >From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >
> >"swiotlb buffer is full" errors occur after repeated initialisation of a
> >device - f.e. suspend/resume or ip link set up/down. This is because memory
> >mapped using dma_map_single() in ravb_ring_format() and ravb_start_xmit()
> >is not released.  Resolve this problem by unmapping descriptors when
> >freeing rings.
> 
>    Could you look into the sh_eth driver which seems to have the same issue?

Sure, I will check.

> >Note, ravb_tx_free() is moved but not otherwise modified by this patch.
> 
>    This is not true anymore BTW.

Thanks for noticing, I'll fix that.

> >Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >[simon: reworked]
> >Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> 
> MBR, Sergei
> 
