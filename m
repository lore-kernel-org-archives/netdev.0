From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] bnx2: Fix lost MSI-X problem on 5709 NICs.
Date: Tue, 27 Apr 2010 14:38:25 -0700 (PDT)
Message-ID: <20100427.143825.216754145.davem@davemloft.net>
References: <1272403691-2934-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, jfeeney@redhat.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36840
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757159Ab0D0ViU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 17:38:20 -0400
In-Reply-To: <1272403691-2934-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 27 Apr 2010 14:28:09 -0700

> It has been reported that under certain heavy traffic conditions in MSI-X
> mode, the driver can lose an MSI-X vector causing all packets in the
> associated rx/tx ring pair to be dropped.  The problem is caused by
> the chip dropping the write to unmask the MSI-X vector by the kernel
> (when migrating the IRQ for example).
> 
> This can be prevented by increasing the GRC timeout value for these
> register read and write operations.
> 
> Thanks to Dell for helping us debug this problem.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied to net-2.6
