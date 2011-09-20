From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 2/2 v2] GRETH: avoid overwrite IP-stack's IP-frags
 checksum
Date: Tue, 20 Sep 2011 15:16:35 -0400 (EDT)
Message-ID: <20110920.151635.261516994102378668.davem@redhat.com>
References: <1315581474-4430-1-git-send-email-daniel@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com,
	eric.dumazet@gmail.com
To: daniel@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038Ab1ITTQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 15:16:40 -0400
In-Reply-To: <1315581474-4430-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Hellstrom <daniel@gaisler.com>
Date: Fri,  9 Sep 2011 17:17:54 +0200

> The GRETH GBIT core does not do checksum offloading for IP
> segmentation. This patch adds a check in the xmit function to
> determine if the stack has calculated the checksum for us.
> 
> Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>

Applied.
