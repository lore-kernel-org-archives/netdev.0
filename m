From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: fix heap info leak in PACKET_DIAG_MCLIST
 sock_diag interface
Date: Thu, 14 Apr 2016 00:47:24 -0400 (EDT)
Message-ID: <20160414.004724.860240909570915881.davem@davemloft.net>
References: <1460285548-832-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, xemul@parallels.com
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbcDNEr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 00:47:27 -0400
In-Reply-To: <1460285548-832-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Sun, 10 Apr 2016 12:52:28 +0200

> Because we miss to wipe the remainder of i->addr[] in packet_mc_add(),
> pdiag_put_mclist() leaks uninitialized heap bytes via the
> PACKET_DIAG_MCLIST netlink attribute.
> 
> Fix this by explicitly memset(0)ing the remaining bytes in i->addr[].
> 
> Fixes: eea68e2f1a00 ("packet: Report socket mclist info via diag module")
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Applied and queued up for -stable, thanks.
