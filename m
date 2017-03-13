From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC iproute v1 1/4] afnetns: add iproute bits for
 afnetns
Date: Mon, 13 Mar 2017 08:10:06 -0700
Message-ID: <20170313081006.78b3af9d@xeon-e3>
References: <20170312230138.5096-1-hannes@stressinduktion.org>
        <20170312230138.5096-2-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33928 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751703AbdCMPKR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:10:17 -0400
Received: by mail-pf0-f182.google.com with SMTP id v190so70358422pfb.1
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 08:10:16 -0700 (PDT)
In-Reply-To: <20170312230138.5096-2-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Mar 2017 00:01:35 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> diff --git a/include/namespace.h b/include/namespace.h
> index 51324b21ba0cd5..acecc8c1f0d2b8 100644
> --- a/include/namespace.h
> +++ b/include/namespace.h
> @@ -7,6 +7,7 @@
>  #include <sys/syscall.h>
>  #include <errno.h>
>  
> +#define AFNETNS_RUN_DIR "/var/run/afnetns"
>  #define NETNS_RUN_DIR "/var/run/netns"
>  #define NETNS_ETC_DIR "/etc/netns"
>  
> @@ -14,6 +15,10 @@
>  #define CLONE_NEWNET 0x40000000	/* New network namespace (lo, device, names sockets, etc) */
>  #endif
>  
> +#ifndef CLONE_NEWAFNET
> +#define CLONE_NEWAFNET	0x00001000	/* Clone new afnet context */
> +#endif
> +

These bits really need to come from a kernel exported header.
