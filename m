From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6] cnic: Fix panic in
 cnic_iscsi_nl_msg_recv() when device is down.
Date: Fri, 26 Feb 2010 02:11:24 -0800 (PST)
Message-ID: <20100226.021124.01042277.davem@davemloft.net>
References: <1267058529-18454-1-git-send-email-mchan@broadcom.com>
	<1267058529-18454-2-git-send-email-mchan@broadcom.com>
	<1267058529-18454-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50676
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752860Ab0BZKLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 05:11:06 -0500
In-Reply-To: <1267058529-18454-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 24 Feb 2010 16:42:06 -0800

> Some data structures are freed when the device is down and it will
> crash if an ISCSI netlink message is received.  Add RCU protection
> to prevent this.  In the shutdown path, ulp_ops[CNIC_ULP_L4] is
> assigned NULL and rcu_synchronized before freeing the data
> structures.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
