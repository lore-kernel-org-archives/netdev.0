From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix forwarding of IPv6
Date: Fri, 13 May 2011 16:03:37 -0400 (EDT)
Message-ID: <20110513.160337.577278090119895974.davem@davemloft.net>
References: <20110510151100.52a9f8fa@nehalam>
	<20110510233540.GJ6397@morgul.net>
	<20110513125314.66861b31@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: noahm@debian.org, herbert@gondor.hengli.com.au,
	ben@decadent.org.uk, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801Ab1EMUEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 16:04:20 -0400
In-Reply-To: <20110513125314.66861b31@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 13 May 2011 12:53:14 -0700

> The commit 6b1e960fdbd75dcd9bcc3ba5ff8898ff1ad30b6e
>     bridge: Reset IPCB when entering IP stack on NF_FORWARD
> broke forwarding of IPV6 packets in bridge because it would
> call bp_parse_ip_options with an IPV6 packet.
> 
> Reported-by: Noah Meyerhans <noahm@debian.org>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Patch against net-next-2.6 but must be applied to net-2.6
> and stable as well

Applied and queued up for -stable, thanks!
