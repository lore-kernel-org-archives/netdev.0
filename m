From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip tuntap: Added missing commands in usage
Date: Sun, 28 Sep 2014 16:20:39 -0700
Message-ID: <20140928162039.3a0477f2@urahara>
References: <1410902651-9240-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:40976 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbaI1XU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 19:20:56 -0400
Received: by mail-pa0-f54.google.com with SMTP id ey11so4746645pad.41
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 16:20:55 -0700 (PDT)
In-Reply-To: <1410902651-9240-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Sep 2014 00:24:11 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> show, list, lst and help commands were not printed in usage.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  ip/iptuntap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/iptuntap.c b/ip/iptuntap.c
> index 2391af2..0ce64a6 100644
> --- a/ip/iptuntap.c
> +++ b/ip/iptuntap.c
> @@ -36,7 +36,7 @@ static void usage(void) __attribute__((noreturn));
>  
>  static void usage(void)
>  {
> -	fprintf(stderr, "Usage: ip tuntap { add | del } [ dev PHYS_DEV ] \n");
> +	fprintf(stderr, "Usage: ip tuntap { add | del | show | list | lst | help } [ dev PHYS_DEV ] \n");
>  	fprintf(stderr, "          [ mode { tun | tap } ] [ user USER ] [ group GROUP ]\n");
>  	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ] [ multi_queue ]\n");
>  	fprintf(stderr, "\n");

both tuntap patches applied
