From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 0/7] IPSec offload improvements
Date: Thu, 3 Aug 2017 13:02:41 +0200
Message-ID: <20170803110241.GJ2631@secunet.com>
References: <20170801094910.14895-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:48882 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751895AbdHCLCo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 07:02:44 -0400
Content-Disposition: inline
In-Reply-To: <20170801094910.14895-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 01, 2017 at 12:49:03PM +0300, ilant@mellanox.com wrote:
> From: Ilan Tayari <ilant@mellanox.com>
> 
> Hi Steffen,
> 
> This patchset introduces several improvements to IPSec offload.
> We would like to see these merged in 4.14.
> 
> Patches 1-4 add RX checksum offload support.
> This gives a big performance boost.
> These patches have been submitted before but were not merged.
> Note that patches 1-2 changed slightly with a call to skb_pull_rcsum.
> 
> Patch 5 adds automatic loading of XFRM offload modules, but only
> if crypto-offload is explicitly requested by user.
> This avoid issues in the field where user forgets to load the
> module manually and so crypto-offload does not happen.
> 
> Patch 6 fixes the leftover xfrm_offload in RX SKBs.
> This solves some issues with forwarding.
> 
> Patch 7 allows IPSec GSO on local sockets, with or without
> crypto-offload.
> This also gives a large performance boost.
> 
> Thanks,
> Ilan.
> 
> Ilan Tayari (4):
>   esp4: Support RX checksum with crypto offload
>   esp6: Support RX checksum with crypto offload
>   xfrm: Auto-load xfrm offload modules
>   xfrm: Clear RX SKB secpath xfrm_offload
> 
> Steffen Klassert (1):
>   net: Allow IPsec GSO for local sockets
> 
> Yossi Kuperman (2):
>   xfrm6: Fix CHECKSUM_COMPLETE after IPv6 header push
>   esp6: Fix RX checksum after header pull

All applied to ipsec-next, thanks a lot!
