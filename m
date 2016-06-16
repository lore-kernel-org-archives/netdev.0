From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] net-next: mediatek: IRQ cleanups, fixes and
 grouping
Date: Wed, 15 Jun 2016 22:20:50 -0700 (PDT)
Message-ID: <20160615.222050.2210130284846212716.davem@davemloft.net>
References: <1466002730-58476-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@nbd.name, keyhaede@gmail.com, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: john@phrozen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbcFPFUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 01:20:51 -0400
In-Reply-To: <1466002730-58476-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <john@phrozen.org>
Date: Wed, 15 Jun 2016 16:58:46 +0200

> This series contains 2 small code cleanups that are leftovers from the
> MIPS support. There is also a small fix that adds proper locking to the
> code accessing the IRQ registers. Without this fix we saw deadlocks caused
> by the last patch of the series, which adds IRQ grouping. The grouping
> feature allows us to use different IRQs for TX and RX. By doing so we can
> use affinity to let the SoC handle the IRQs on different cores.

This patch series doesn't apply cleanly to the net-next tree, I get rejects
on patch #4.
