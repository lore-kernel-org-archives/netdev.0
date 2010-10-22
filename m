From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] vlan: Calling vlan_hwaccel_do_receive() is always
 valid.
Date: Thu, 21 Oct 2010 20:00:27 -0700 (PDT)
Message-ID: <20101021.200027.71112639.davem@davemloft.net>
References: <1287696643-9695-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754071Ab0JVDAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 23:00:05 -0400
In-Reply-To: <1287696643-9695-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Thu, 21 Oct 2010 14:30:42 -0700

> It is now acceptable to receive vlan tagged packets at any time,
> even if CONFIG_VLAN_8021Q is not set.  This means that calling
> vlan_hwaccel_do_receive() should not result in BUG() but rather just
> behave as if there were no vlan devices configured.
> 
> Reported-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
