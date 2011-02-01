From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2x, cnic: Consolidate iSCSI/FCoE
 shared mem logic in bnx2x
Date: Mon, 31 Jan 2011 20:44:57 -0800 (PST)
Message-ID: <20110131.204457.189681258.davem@davemloft.net>
References: <1296520757-5387-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40890
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753172Ab1BAEoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 23:44:22 -0500
In-Reply-To: <1296520757-5387-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 31 Jan 2011 16:39:17 -0800

> From: Vladislav Zolotarov <vladz@broadcom.com>
> 
> Move all shared mem code to bnx2x to avoid code duplication.  bnx2x now
> performs:
> 
> - Read the FCoE and iSCSI max connection information.
> - Read the iSCSI and FCoE MACs from NPAR configuration in shmem.
> - Block the CNIC for the current function if there is neither FCoE nor
>   iSCSI valid configuration by returning NULL from bnx2x_cnic_probe().
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
