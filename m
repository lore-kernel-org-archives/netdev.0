From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/9] Neterion: Driver help file
Date: Fri, 27 Mar 2009 15:46:28 -0700 (PDT)
Message-ID: <20090327.154628.195613387.davem@davemloft.net>
References: <1238194447.5516.374.camel@flash>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59095
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753174AbZC0Wqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 18:46:40 -0400
In-Reply-To: <1238194447.5516.374.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ramkrishna Vepa <ram.vepa@neterion.com>
Date: 27 Mar 2009 14:54:08 -0800

I'm not apply any of this patch set.

> +4) Performance Suggestions:
> +---------------------------
> +
> +- Set MTU to maximum - 9000 for switch setup, 9600 for back-to-back.
> +For MTU 1500:
> +-------------
> +### IPV4 specific settings
> +# turns TCP timestamp support off, default 1, reduces CPU use
> +$sysctl -w net.ipv4.tcp_timestamps = "0"

You have got to be kidding me.

I see this garbage in the "tuning suggestions" sections of
various manuals of proprietary products for Linux.

But there is no way I'm letting this junk slip into Linux proper too.

All of these suggestions are ill founded, have side effects that are
not even passively mentioned in these "suggestions", and are even
dangerous.

Do you even know the security implications of turning off TCP timestamps?
Do you know or even feel the need to mention the performance implications
over long haul networks of turning timestamps off?

If the default sysctl parameters are not correct, let's fix them instead
of telling every user how to break their system with "tweaks".
