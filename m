From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] cnic: Do not call bnx2i when bnx2i is
 calling cnic_unregister_driver()
Date: Mon, 03 Jan 2011 19:08:35 -0800 (PST)
Message-ID: <20110103.190835.112600856.davem@davemloft.net>
References: <1294104106-9758-1-git-send-email-mchan@broadcom.com>
	<1294104106-9758-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39229
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751181Ab1ADDIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 22:08:04 -0500
In-Reply-To: <1294104106-9758-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 3 Jan 2011 17:21:46 -0800

> We should call bnx2i to send the iSCSI netlink message earlier in
> cnic_unregister_device().  By the time cnic_unregister_driver() is
> called, bnx2i may have freed data structures used by the upcalls.
> 
> Update version to 2.2.12.
> 
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
