From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] cnic: Fix rare race condition during
 iSCSI disconnect.
Date: Wed, 05 Dec 2012 16:26:34 -0500 (EST)
Message-ID: <20121205.162634.2265031655079378883.davem@davemloft.net>
References: <1354738215-6644-1-git-send-email-mchan@broadcom.com>
	<1354738215-6644-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096Ab2LEV0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:26:35 -0500
In-Reply-To: <1354738215-6644-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 5 Dec 2012 12:10:15 -0800

> From: Eddie Wai <eddie.wai@broadcom.com>
> 
> If the initiator and target try to close the connection at about the same
> time, there is a race condition in the termination sequence for bnx2x.
> Fix the problem by waiting for the remote termination to complete before
> deleting the Connection ID.  This will prevent the firmware assert.
> 
> Update version to 2.5.15.
> 
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
