From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v3 net-next 3/8] tunnel: introduce udp_tun_rx_dst()
Date: Tue, 25 Aug 2015 19:46:39 +0200
Message-ID: <20150825174639.GB3707@pox.localdomain>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
 <1440438195-5695-4-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:37132 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbbHYRql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 13:46:41 -0400
Received: by widdq5 with SMTP id dq5so21955603wid.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 10:46:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440438195-5695-4-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/15 at 10:43am, Pravin B Shelar wrote:
> Introduce function udp_tun_rx_dst() to initialize tunnel dst on
> receive path.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> +	if (family == AF_INET)
> +		tun_dst = ip_tun_rx_dst(skb, flags, tunnel_id, md_size);
> +	else
> +		tun_dst = ipv6_tun_rx_dst(skb, flags, tunnel_id, md_size);

Might look a bit cleaner if you add the address specific code inside
ip_tun_rx_dst() directly. I'm fine either way though.

Acked-by: Thomas Graf <tgraf@suug.ch>
