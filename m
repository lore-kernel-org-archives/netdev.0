From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: socket: error on a negative msg_namelen
Date: Wed, 12 Mar 2014 16:31:30 -0400 (EDT)
Message-ID: <20140312.163130.1932426314100805531.davem@davemloft.net>
References: <1394539107-1432-1-git-send-email-matthew.leach@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Will.Deacon@arm.com, Mark.Rutland@arm.com,
	dan.carpenter@oracle.com
To: matthew.leach@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbaCLUbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:31:32 -0400
In-Reply-To: <1394539107-1432-1-git-send-email-matthew.leach@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Leach <matthew.leach@arm.com>
Date: Tue, 11 Mar 2014 11:58:27 +0000

> When copying in a struct msghdr from the user, if the user has set the
> msg_namelen parameter to a negative value it gets clamped to a valid
> size due to a comparison between signed and unsigned values.
> 
> Ensure the syscall errors when the user passes in a negative value.
> 
> Signed-off-by: Matthew Leach <matthew.leach@arm.com>

Applied and queued up for -stable, thanks.
