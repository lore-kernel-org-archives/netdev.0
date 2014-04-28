From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: exit the loop when invalid index
 occurs
Date: Mon, 28 Apr 2014 13:29:05 -0400 (EDT)
Message-ID: <20140428.132905.1371318427947470918.davem@davemloft.net>
References: <1398586838-21474-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, VenkatKumar.Duvvuru@Emulex.Com
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756489AbaD1TXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:23:14 -0400
In-Reply-To: <1398586838-21474-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Sun, 27 Apr 2014 02:20:38 -0600

> The commit 3de0b592394d ("ethtool: Support for configurable RSS hash
> key") introduced a new function ethtool_copy_validate_indir() with
> full iteration of the loop to validate the ring indices, which could
> be an overkill. To minimize the impact, we ought to exit the loop as
> soon as the invalid index occurs for the very first time. The
> remaining loop simply doesn't serve any more purpose.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Cc: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>

Applied.
