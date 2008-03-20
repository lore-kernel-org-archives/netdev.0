From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH/RFC v3] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig
	symbol
Date: Thu, 20 Mar 2008 12:09:11 -0700
Message-ID: <1206040151.17059.10.camel@brick>
References: <1206023695.16475.137.camel@johannes.berg>
	 <20080320181310.GA17884@uranus.ravnborg.org>
	 <1206038373.16475.150.camel@johannes.berg>
	 (sfid-20080320_184016_333600_B74BDE6D)  <1206038734.16475.153.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>, Daniel Drake <dsd@gentoo.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:12979 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbYCTTJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 15:09:15 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1180215wah.23
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 12:09:14 -0700 (PDT)
In-Reply-To: <1206038734.16475.153.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-03-20 at 19:45 +0100, Johannes Berg wrote:
> +For some ethernet hardware that cannot DMA to unaligned addresses like
> +4*n+2 or non-ethernet hardware, this can be a problem, and it is then
> +required to copy the incoming frame into an aligned buffer. Because this is
> +unnecessary on architectures that can do unaligned accesses, the code can be
> +made depend on CONFIG_HAVE_UNALIGNED_ACCESS_SUPPORT like so:
> +
> +#ifdef CONFIG_HAVE_UNALIGNED_ACCESS_SUPPORT
> +	skb = original skb
> +#else
> +	skb = copy skb
> +#endif
> +

Couldn't this just be made an inline in a networking header somewhere,
instead of ifdefs in the code?

Harvey

