From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ravb: do not use zero-length alighment DMA request
Date: Fri, 13 Jan 2017 14:14:26 +0100
Message-ID: <20170113131426.GA12172@verge.net.au>
References: <1484312940-11147-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Masaru Nagai <masaru.nagai.vx@renesas.com>
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:35395 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751771AbdAMNOc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 08:14:32 -0500
Content-Disposition: inline
In-Reply-To: <1484312940-11147-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 02:09:00PM +0100, Simon Horman wrote:
> From: Masaru Nagai <masaru.nagai.vx@renesas.com>
> 
> Due to alignment requirements of the hardware transmissions are split into
> two DMA descriptors, a small padding descriptor of 0 - 3 bytes in length
> followed by a descriptor for rest of the packet.
> 
> In the case of IP packets the first descriptor will never be zero due to
> the way that the stack aligns buffers for IP packets. However, for non-IP
> packets it may be zero.

...

Apologies, I forgot to include v2 in the subject prefix.
