From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ASIX: Use only 11 bits of header for data size
Date: Wed, 27 Jul 2011 22:40:29 -0700 (PDT)
Message-ID: <20110727.224029.619127041796367339.davem@davemloft.net>
References: <1311734687-23551-1-git-send-email-marek.vasut@gmail.com>
	<1311734687-23551-2-git-send-email-marek.vasut@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, gregkh@suse.de
To: marek.vasut@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754705Ab1G1Fkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:40:32 -0400
In-Reply-To: <1311734687-23551-2-git-send-email-marek.vasut@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marek.vasut@gmail.com>
Date: Wed, 27 Jul 2011 04:44:47 +0200

> The AX88772B uses only 11 bits of the header for the actual size. The other bits
> are used for something else. This causes dmesg full of messages:
> 
> 	asix_rx_fixup() Bad Header Length
> 
> This patch trims the check to only 11 bits. I believe on older chips, the
> remaining 5 top bits are unused.
> 
> Signed-off-by: Marek Vasut <marek.vasut@gmail.com>

Applied.
