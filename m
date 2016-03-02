From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: Fix musl compatibility
Date: Wed, 2 Mar 2016 11:03:40 -0800
Message-ID: <20160302110340.0d73e5ee@xeon-e3>
References: <20160222113447.GA10262@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Loganaden Velvindron <logan@hackers.mu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34558 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755946AbcCBTD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:03:28 -0500
Received: by mail-pf0-f180.google.com with SMTP id 4so60320747pfd.1
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 11:03:27 -0800 (PST)
In-Reply-To: <20160222113447.GA10262@mx.elandsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Feb 2016 03:34:48 -0800
Loganaden Velvindron <logan@hackers.mu> wrote:

> diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
> index b71b4c9..3e4e6ae 100644
> --- a/include/linux/netfilter.h
> +++ b/include/linux/netfilter.h
> @@ -4,8 +4,6 @@
>  #include <linux/types.h>
>  
>  #include <linux/sysctl.h>
> -#include <linux/in.h>
> -#include <linux/in6.h>
>  
>  /* Responses from hook functio

Sorry, I have to reject this.
All include files in include/linux come from headers automatically generated from upstream
Linux source. This is the only way to ensure long term ABI/API consistency
with kernel.

Either fix musl or submit patches to upstream kernel and get them merged.
