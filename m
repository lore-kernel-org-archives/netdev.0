From: Paul Barker <paul@paulbarker.me.uk>
Subject: Re: [ethtool][PATCH] Fix build with musl by using more common typedefs
Date: Thu, 13 Nov 2014 11:22:01 +0000
Message-ID: <CANyK_8cZ3oCnwrbX4RbY8W4gN4N-o_aFg68CpX0co0_GMcQR6A@mail.gmail.com>
References: <1414323849-5739-1-git-send-email-paul@paulbarker.me.uk> <1414323849-5739-2-git-send-email-paul@paulbarker.me.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paul Barker <paul@paulbarker.me.uk>,
	John Spencer <maillist-linux@barfooze.de>
To: Ben Hutchings <bwh@kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:41058 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932328AbaKMLWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 06:22:42 -0500
Received: by mail-qg0-f50.google.com with SMTP id a108so10420255qge.9
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 03:22:41 -0800 (PST)
In-Reply-To: <1414323849-5739-2-git-send-email-paul@paulbarker.me.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 October 2014 11:44, Paul Barker <paul@paulbarker.me.uk> wrote:
> When using musl as the standard C library, type names such as '__int32_t' are
> not defined. Instead we must use the more commonly defined type names such as
> 'int32_t', which are defined in <stdint.h>.
>
> Signed-off-by: John Spencer <maillist-linux@barfooze.de>
> Signed-off-by: Paul Barker <paul@paulbarker.me.uk>
> ---
>  internal.h | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/internal.h b/internal.h
> index a9dfae0..262a39f 100644
> --- a/internal.h
> +++ b/internal.h
> @@ -7,6 +7,7 @@
>  #include "ethtool-config.h"
>  #endif
>  #include <stdio.h>
> +#include <stdint.h>
>  #include <stdlib.h>
>  #include <string.h>
>  #include <sys/types.h>
> @@ -17,16 +18,16 @@
>
>  /* ethtool.h expects these to be defined by <linux/types.h> */
>  #ifndef HAVE_BE_TYPES
> -typedef __uint16_t __be16;
> -typedef __uint32_t __be32;
> +typedef uint16_t __be16;
> +typedef uint32_t __be32;
>  typedef unsigned long long __be64;
>  #endif
>
>  typedef unsigned long long u64;
> -typedef __uint32_t u32;
> -typedef __uint16_t u16;
> -typedef __uint8_t u8;
> -typedef __int32_t s32;
> +typedef uint32_t u32;
> +typedef uint16_t u16;
> +typedef uint8_t u8;
> +typedef int32_t s32;
>
>  #include "ethtool-copy.h"
>  #include "net_tstamp-copy.h"
> --
> 2.1.2
>

Ping. Could you let me know if this patch is acceptable or not?

Cheers,

-- 
Paul Barker

Email: paul@paulbarker.me.uk
http://www.paulbarker.me.uk
