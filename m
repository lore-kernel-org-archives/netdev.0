From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp_offload: Allow device GRO without
 checksum-complete
Date: Mon, 24 Aug 2015 13:15:28 -0700
Message-ID: <1440447328.8932.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440444853-614524-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sramamur@linux.vnet.ibm.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34252 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626AbbHXUPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 16:15:31 -0400
Received: by pabzx8 with SMTP id zx8so13947347pab.1
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 13:15:30 -0700 (PDT)
In-Reply-To: <1440444853-614524-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-08-24 at 12:34 -0700, Tom Herbert wrote:

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index c0a15e7..1d91227 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -130,6 +130,9 @@ EXPORT_SYMBOL(sysctl_udp_wmem_min);
>  atomic_long_t udp_memory_allocated;
>  EXPORT_SYMBOL(udp_memory_allocated);
>  
> +int sysctl_udp_gro_nocsum_ok;
> +EXPORT_SYMBOL(sysctl_udp_gro_nocsum_ok);
> +

1) Why is this exported ?

2) I do not believe it is specific to UDP path.

  We could have the same sysctl for GRE or IPIP or XXX encaps ?
