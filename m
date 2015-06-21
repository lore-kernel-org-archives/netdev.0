From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next RFC v2 3/3] mpls: support for ip tunnels
Date: Sun, 21 Jun 2015 22:27:28 +0200
Message-ID: <20150621202728.GB4228@pox.localdomain>
References: <1434689355-4088-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:36750 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186AbbFUU1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 16:27:31 -0400
Received: by wguu7 with SMTP id u7so53815583wgu.3
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 13:27:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434689355-4088-4-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/15 at 09:49pm, Roopa Prabhu wrote:
> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
> index 17bde79..3e87a6b 100644
> --- a/net/mpls/Kconfig
> +++ b/net/mpls/Kconfig
> @@ -27,4 +27,9 @@ config MPLS_ROUTING
>  	help
>  	 Add support for forwarding of mpls packets.
>  
> +config MPLS_IPTUNNEL
> +	tristate "MPLS: IP over MPLS tunnel support"
> +	help
> +	 Light weight tunnel handling for mpls tunnel packets
> +

I assume this should select CONFIG_LWTUNNEL
