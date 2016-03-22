From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] fsl/fman: Workaround for Errata A-007273
Date: Tue, 22 Mar 2016 15:58:32 -0400 (EDT)
Message-ID: <20160322.155832.3597898197447163.davem@redhat.com>
References: <1458594492-15529-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scottwood@freescale.com,
	madalin.bucur@freescale.com
To: igal.liberman@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751893AbcCVT6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 15:58:34 -0400
In-Reply-To: <1458594492-15529-1-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <igal.liberman@freescale.com>
Date: Mon, 21 Mar 2016 23:08:11 +0200

> From: Igal Liberman <igal.liberman@freescale.com>
> 
> Errata A-007273 (For FMan V3 devices only):
> FMan soft reset is not finished properly if one
> of the Ethernet MAC clocks is disabled
> 
> Workaround:
> Re-enable all disabled MAC clocks through the DCFG_CCSR_DEVDISR2
> register prior to issuing an FMAN soft reset.
> Re-disable the MAC clocks after the FMAN soft reset is done.
> 
> Signed-off-by: Igal Liberman <igal.liberman@freescale.com>

Applied, thanks.
