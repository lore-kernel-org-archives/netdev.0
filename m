From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH trivial] net: add bbr to config DEFAULT_TCP_CONG
Date: Fri, 14 Oct 2016 09:43:46 +0200
Message-ID: <1476431026.5650.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161014073333.GA10006@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34921 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757333AbcJNHnw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 03:43:52 -0400
Received: by mail-pa0-f68.google.com with SMTP id qn10so5771570pac.2
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 00:43:51 -0700 (PDT)
In-Reply-To: <20161014073333.GA10006@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-10-14 at 09:33 +0200, Markus Trippelsdorf wrote:
> While playing with BBR I noticed that it was missing in the list of
> possible config DEFAULT_TCP_CONG choices. Fixed thusly.
> 
> Signed-off-by: Markus Trippelsdorf <markus@trippelsdorf.de>
> 
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index 300b06888fdf..b54b3ca939db 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -715,6 +715,7 @@ config DEFAULT_TCP_CONG
>  	default "reno" if DEFAULT_RENO
>  	default "dctcp" if DEFAULT_DCTCP
>  	default "cdg" if DEFAULT_CDG
> +	default "bbr" if DEFAULT_BBR
>  	default "cubic"

Not sure if we want this at this moment.

BBR needs FQ packet scheduler, and this is not exactly trivial to
achieve.
