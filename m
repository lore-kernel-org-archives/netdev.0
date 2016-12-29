From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] vif queue counters from int to long
Date: Thu, 29 Dec 2016 10:47:09 +0000
Message-ID: <20161229104709.GY28690@citrix.com>
References: <585D3E23.10509@greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <wei.liu2@citrix.com>
To: Mart van Santen <mart@greenhost.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:60494 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752399AbcL2KrL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 05:47:11 -0500
Content-Disposition: inline
In-Reply-To: <585D3E23.10509@greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 23, 2016 at 04:09:23PM +0100, Mart van Santen wrote:
> 
> Hello,
> 
> This patch fixes an issue where counters in the queue have type int,
> while the counters of the vif itself are specified as long. This can
> cause incorrect reporting of tx/rx values of the vif interface.
> More extensively reported on xen-devel mailinglist.
> 

Hello,

Please also CC xen-devel@lists.xenproject.org for your future patch(es).
And please note that the most up to date maintainer information should
be used.

Wei.

> 
> 
> Signed-off-by: Mart van Santen <mart@greenhost.nl>
> --- a/drivers/net/xen-netback/common.h  2016-12-22 15:41:07.785535748 +0000
> +++ b/drivers/net/xen-netback/common.h  2016-12-23 13:08:18.123080064 +0000
> @@ -113,10 +113,10 @@ struct xenvif_stats {
>          * A subset of struct net_device_stats that contains only the
>          * fields that are updated in netback.c for each queue.
>          */
> -       unsigned int rx_bytes;
> -       unsigned int rx_packets;
> -       unsigned int tx_bytes;
> -       unsigned int tx_packets;
> +       unsigned long rx_bytes;
> +       unsigned long rx_packets;
> +       unsigned long tx_bytes;
> +       unsigned long tx_packets;
> 
>         /* Additional stats used by xenvif */
>         unsigned long rx_gso_checksum_fixup;
> 
> -- 
> Mart van Santen
> Greenhost
> E: mart@greenhost.nl
> T: +31 20 4890444
> W: https://greenhost.nl
> 
> A PGP signature can be attached to this e-mail,
> you need PGP software to verify it. 
> My public key is available in keyserver(s)
> see: http://tinyurl.com/openpgp-manual
> 
> PGP Fingerprint: CA85 EB11 2B70 042D AF66  B29A 6437 01A1 10A3 D3A5
> 
> 
