From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: avoid OOPS if root port not found
Date: Tue, 30 Apr 2013 15:52:25 -0400 (EDT)
Message-ID: <20130430.155225.263723275782712153.davem@davemloft.net>
References: <20130430082927.56aa0785@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933540Ab3D3Tw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 15:52:27 -0400
In-Reply-To: <20130430082927.56aa0785@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 30 Apr 2013 08:29:27 -0700

> Bridge can crash while trying to send topology change packet.
> This happens if root port can't be found. This was reported by user
> but currently unable to reproduce it easily. The STP conditions that cause
> this are not known yet, but the problem doesn't have to be fatal.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Right, there's no reason we should flat-out crash because of this.

Applied, thanks.
