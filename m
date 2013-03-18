From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Mon, 18 Mar 2013 12:24:09 -0700
Message-ID: <20130318122409.00c01106@nehalam.linuxnetplumber.net>
References: <1363630405-1672-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:63132 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754963Ab3CRTaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 15:30:52 -0400
Received: by mail-pb0-f53.google.com with SMTP id un1so6681339pbc.12
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 12:30:52 -0700 (PDT)
In-Reply-To: <1363630405-1672-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Mar 2013 11:13:25 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index 7944df7..2073226 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -186,9 +186,14 @@ config NET_IPGRE_DEMUX
>  	 This is helper module to demultiplex GRE packets on GRE version field criteria.
>  	 Required by ip_gre and pptp modules.
>  
> +config NET_IP_TUNNEL
> +	tristate
> +	default n
> +

Won't this break existing kernel config's, shouldn't this default y?
