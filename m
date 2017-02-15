From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC v2 ipsec-next 0/6] IPsec GRO layer decapsulation
Date: Wed, 15 Feb 2017 13:25:29 +0100
Message-ID: <20170215122529.GV30338@gauss.secunet.com>
References: <1486979881-24635-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46086 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751666AbdBOMZs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 07:25:48 -0500
Content-Disposition: inline
In-Reply-To: <1486979881-24635-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 10:57:55AM +0100, Steffen Klassert wrote:
> This patchset adds a software GRO codepath for IPsec ESP.
> The ESP gro_receive callback functions decapsulate the
> ESP packets at the GRO layer and reinject them back with
> gro_cells_receive(). This saves a complete round through
> the stack for IPsec ESP packets.
> 
> We also need this for ESP HW offload, because HW decrypt but
> does not decapsulate the packet. We need to decapsulate before
> the inbound policy check, otherwise this check will fail.
> 
> Patches 2 an 3 prepare the generic code for packet consuming
> gro callbacks.
> 
> Changes from v1:
> 
> - Add the 'xfrm: Extend the sec_path for IPsec offloading'
>   patch and use the secpath to encode GRO calls.
> 
> - Coding style fixes.

I have not got any further feedback, so I applied this
series to ipsec-next.
