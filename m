From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: fix build dependency on VxLAN
Date: Tue, 01 Apr 2014 16:27:00 -0400 (EDT)
Message-ID: <20140401.162700.767983330820882279.davem@davemloft.net>
References: <1396335839-2193-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55178 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbaDAU1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:27:01 -0400
In-Reply-To: <1396335839-2193-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 1 Apr 2014 12:33:59 +0530

> Introduce a CONFIG_BE2NET_VXLAN define to control be2net's build
> dependency on the VXLAN driver.
> 
> Without this fix, the kernel build fails when VxLAN driver is
> selected to be built as a module while be2net is built-in.
> 
> fixes: c9c47142 ("be2net: csum, tso and rss steering offload support for VxLAN")
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
