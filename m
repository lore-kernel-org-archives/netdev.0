From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix struct inet_timewait_sock bitfield annotation
Date: Tue, 20 Oct 2009 01:14:26 -0700 (PDT)
Message-ID: <20091020.011426.39733892.davem@davemloft.net>
References: <4ADC27F3.5050508@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60209
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750795AbZJTIOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 04:14:03 -0400
In-Reply-To: <4ADC27F3.5050508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Oct 2009 10:48:51 +0200

> commit 9e337b0f (net: annotate inet_timewait_sock bitfields)
> added 4/8 bytes in struct inet_timewait_sock.
> 
> Fix this by declaring tw_ipv6_offset in the 'flags' bitfield
> The 14 bits hole is named tw_pad to make it cleary apparent.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-2.6, thanks.
