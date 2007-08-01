From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: [PATCH] net/sched: mark "NET_CLS_RSVP6 depends on IPV6"
Date: Wed, 01 Aug 2007 03:49:20 +0200
Message-ID: <46AFE6A0.4070405@googlemail.com>
References: <11859324914084-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chdebra@gmail.com
To: Denis Cheng <crquan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:65355 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757608AbXHABtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 21:49:36 -0400
Received: by mu-out-0910.google.com with SMTP id i10so80236mue
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 18:49:34 -0700 (PDT)
In-Reply-To: <11859324914084-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Cheng wrote:
> Signed-off-by: Denis Cheng <crquan@gmail.com>
> ---
>  net/sched/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 8a74cac..5d3749c 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -300,6 +300,7 @@ config NET_CLS_RSVP
>  config NET_CLS_RSVP6
>  	tristate "IPv6 Resource Reservation Protocol (RSVP6)"
>  	select NET_CLS
> +	depends on IPV6
>  	---help---
>  	  The Resource Reservation Protocol (RSVP) permits end systems to
>  	  request a minimum and maximum data flow rate for a connection; this

	
I thought the same but ... see 

http://marc.info/?l=linux-kernel&m=118440958516205&w=2
http://marc.info/?l=linux-netdev&m=118442747709230&w=2

Regards,

Gabriel
