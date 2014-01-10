From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute: Document the "ip link add index IDX"
 possibility
Date: Thu, 9 Jan 2014 22:43:02 -0800
Message-ID: <20140109224302.3255e92d@nehalam.linuxnetplumber.net>
References: <52C14305.8070401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47259 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaAJGnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 01:43:06 -0500
Received: by mail-pa0-f49.google.com with SMTP id bj1so530300pad.36
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 22:43:05 -0800 (PST)
In-Reply-To: <52C14305.8070401@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Dec 2013 13:55:17 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> Signed-off-by: Pavel Emelyanov <xemul@paralles.com>
> 
> ---
> 
> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
> index 3986a5a..94d07fc 100644
> --- a/man/man8/ip-link.8.in
> +++ b/man/man8/ip-link.8.in
> @@ -39,6 +39,8 @@ ip-link \- network device configuration
>  .br
>  .RB "[ " mtu
>  .IR MTU " ]"
> +.RB "[ " index
> +.IR IDX " ]"
>  .br
>  .RB "[ " numtxqueues
>  .IR QUEUE_COUNT " ]"
> @@ -218,6 +220,10 @@ specifies the number of transmit queues for new device.
>  specifies the number of receive queues for new device.
>  
>  .TP
> +.BI index " IDX "
> +specifies the desired index of the new virtual device. The link creation fails, if the index is busy.
> +
> +.TP
>  VXLAN Type Support
>  For a link of type 
>  .I VXLAN

Applied
