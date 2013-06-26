From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/tg3: Avoid delay during MMIO access
Date: Tue, 25 Jun 2013 17:01:25 -0700 (PDT)
Message-ID: <20130625.170125.60596231117979470.davem@davemloft.net>
References: <1372145072-8559-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	benh@kernel.crashing.org
To: shangw@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586Ab3FZAB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 20:01:26 -0400
In-Reply-To: <1372145072-8559-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <shangw@linux.vnet.ibm.com>
Date: Tue, 25 Jun 2013 15:24:32 +0800

> When the EEH error is the result of a fenced host bridge, MMIO accesses
> can be very slow (milliseconds) to timeout and return all 1's,
> thus causing the driver various timeout loops to take way too long and
> trigger soft-lockup warnings (in addition to taking minutes to recover).
> 
> It might be worthwhile to check if for any of these cases, ffffffff is
> a valid possible value, and if not, bail early since that means the HW
> is either gone or isolated. In the meantime, checking that the PCI channel
> is offline would be workaround of the problem.
> 
> Cc: <stable@vger.kernel.org> # v3.0+
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Applied and queued up for -stable, thanks.
