From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cnic, bnx2i: Fix bug on some bnx2x devices
 that don't support iSCSI
Date: Fri, 02 Aug 2013 15:56:42 -0700 (PDT)
Message-ID: <20130802.155642.905107992445430774.davem@davemloft.net>
References: <1375468103-12341-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eddie.wai@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329Ab3HBW4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 18:56:43 -0400
In-Reply-To: <1375468103-12341-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 2 Aug 2013 11:28:23 -0700

> On some bnx2x devices, iSCSI is determined to be unsupported only after
> firmware is downloaded.  We need to check max_iscsi_conn again after
> NETDEV_UP and block iSCSI init operations.  Without this fix, iscsiadm
> can hang as the firmware will not respond to the iSCSI init message.
> 
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
