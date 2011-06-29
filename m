From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] myri10ge: ensure tx queues remain stopped
Date: Wed, 29 Jun 2011 06:02:29 -0700 (PDT)
Message-ID: <20110629.060229.729493217305114872.davem@davemloft.net>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com
To: mason@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab1F2NCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 09:02:32 -0400
In-Reply-To: <1309187108-12715-1-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <mason@myri.com>
Date: Mon, 27 Jun 2011 10:05:00 -0500

> Ensure that our tx queues remain stopped when we stop them in
> myri10ge_close().  Not doing so can potentially lead to traffic being
> transmitted when the interface is removed, which can lead to NULL
> pointer dereferences.
> 
> Signed-off-by: Jon Mason <mason@myri.com>

Applied.
