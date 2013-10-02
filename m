From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] unix_diag: fix info leak
Date: Wed, 02 Oct 2013 16:08:51 -0400 (EDT)
Message-ID: <20131002.160851.628764791761734053.davem@davemloft.net>
References: <1380571540-15532-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064Ab3JBUIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 16:08:53 -0400
In-Reply-To: <1380571540-15532-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Mon, 30 Sep 2013 22:05:40 +0200

> When filling the netlink message we miss to wipe the pad field,
> therefore leak one byte of heap memory to userland. Fix this by
> setting pad to 0.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Applied and queued up for -stable, thanks!
