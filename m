From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] Avoid in6_addr redefinition
Date: Thu, 19 Nov 2015 14:32:50 -0800
Message-ID: <20151119143250.44a24eb4@xeon-e3>
References: <1447967140-29909-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1447967140-29909-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35814 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbKSWch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 17:32:37 -0500
Received: by pacej9 with SMTP id ej9so94290116pac.2
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 14:32:37 -0800 (PST)
In-Reply-To: <1447967140-29909-2-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Nov 2015 22:05:39 +0100
Thomas Petazzoni <thomas.petazzoni@free-electrons.com> wrote:

> diff --git a/include/libiptc/ipt_kernel_headers.h b/include/libiptc/ipt_kernel_headers.h
> index 7e87828..9566be5 100644
> --- a/include/libiptc/ipt_kernel_headers.h
> +++ b/include/libiptc/ipt_kernel_headers.h
> @@ -15,12 +15,10 @@
>  #else /* libc5 */
>  #include <sys/socket.h>
>  #include <linux/ip.h>
> -#include <linux/in.h>
>  #include <linux/if.h>
>  #include <linux/icmp.h>
>  #include <linux/tcp.h>
>  #include <linux/udp.h>
>  #include <linux/types.h>
> -#include <linux/in6.h>
>  #endif
>  #endif

This header file comes from iptables. Please fix there, otherwise
on next time someone does merge from there it will break.
