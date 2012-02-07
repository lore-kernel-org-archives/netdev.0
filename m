From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH net-next] sh-eth: use netdev stats structure and fix
 dma_map_single
Date: Tue, 07 Feb 2012 18:19:30 +0900
Message-ID: <4F30ECA2.7030603@renesas.com>
References: <1328602641.2476.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor1.renesas.com ([210.160.252.171]:54347 "EHLO
	relmlor1.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756725Ab2BGJTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 04:19:32 -0500
Received: from relmlir3.idc.renesas.com ([10.200.68.153])
 by relmlor1.idc.renesas.com ( SJSMS)
 with ESMTP id <0LZ000G0LN8J2O90@relmlor1.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 Feb 2012 18:19:31 +0900 (JST)
Received: from relmlac3.idc.renesas.com ([10.200.69.23])
 by relmlir3.idc.renesas.com ( SJSMS)
 with ESMTP id <0LZ000IMRN8JDOF0@relmlir3.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 Feb 2012 18:19:31 +0900 (JST)
In-reply-to: <1328602641.2476.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

2012/02/07 17:17, Eric Dumazet wrote:
> No need to maintain a parallel net_device_stats structure in
> sh_eth_private, since we have a generic one in netdev
> 
> Fix two dma_map_single() incorrect parameters, passing skb->tail instead
> of skb->data. Seems that there is no corresponding dmap_unmap_single()
> calls for the moment in this driver.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> ---
> Please test this patch Yoshihiro before we can apply it, thanks !

Thank you for the patch.
I tested this patch and it worked correctly on my environment.
 - ping, NFS, FTP and read the statistics by sysfs

Tested-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Best regards,
Yoshihiro Shimoda
