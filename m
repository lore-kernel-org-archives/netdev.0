From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5 net-next] cnic: Fix race conditions with firmware
Date: Wed, 08 Jun 2011 23:53:06 -0700 (PDT)
Message-ID: <20110608.235306.284248625871815376.davem@davemloft.net>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
	<1307597376-5379-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569Ab1FIGxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 02:53:08 -0400
In-Reply-To: <1307597376-5379-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 8 Jun 2011 22:29:33 -0700

> During iSCSI connection terminations, if the target is also terminating
> at about the same time, the firmware may not complete the driver's
> request to close or reset the connection.  This is fixed by handling
> other events (instead of the expected completion event) as an indication
> that the driver's request has been rejected.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
