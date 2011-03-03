From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] cnic: Fix lost interrupt on bnx2x
Date: Wed, 02 Mar 2011 16:00:24 -0800 (PST)
Message-ID: <20110302.160024.15225911.davem@davemloft.net>
References: <1299106850-23645-1-git-send-email-mchan@broadcom.com>
	<1299106850-23645-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51496
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756500Ab1CBX7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 18:59:47 -0500
In-Reply-To: <1299106850-23645-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 2 Mar 2011 15:00:50 -0800

> We service 2 queues (kcq1 and kcq2) in cnic_service_bnx2x_bh().  If
> the status block index has changed when servicing the kcq2, we must
> go back and check kcq1.  The latest status block index will be used
> to acknowledge the interrupt, and without looping back to check kcq1,
> we may miss events on kcq1.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
