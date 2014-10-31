From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net 2/2] mpls: Allow mpls_gso to be built as module
Date: Fri, 31 Oct 2014 15:49:41 +0900
Message-ID: <20141031064939.GB16156@vergenet.net>
References: <1414655404-1572-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:40390 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760925AbaJaGtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 02:49:51 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so6636028pdb.25
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 23:49:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1414655404-1572-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2014 at 12:50:04AM -0700, Pravin B Shelar wrote:
> Kconfig already allows mpls to be built as module. Following patch
> fixes Makefile to do same.

Thanks, and sorry for messing that up.

Acked-by: Simon Horman <simon.horman@netronome.com>

> CC: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  net/mpls/Makefile |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/mpls/Makefile b/net/mpls/Makefile
> index 0a3c171..6dec088 100644
> --- a/net/mpls/Makefile
> +++ b/net/mpls/Makefile
> @@ -1,4 +1,4 @@
>  #
>  # Makefile for MPLS.
>  #
> -obj-y += mpls_gso.o
> +obj-$(CONFIG_NET_MPLS_GSO) += mpls_gso.o
> -- 
> 1.7.1
> 
