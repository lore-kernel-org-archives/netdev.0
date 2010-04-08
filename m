From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cnic: Fix crash during bnx2x MTU change.
Date: Wed, 07 Apr 2010 20:54:04 -0700 (PDT)
Message-ID: <20100407.205404.118402919.davem@davemloft.net>
References: <1270518241-13750-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53550
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755435Ab0DHDyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 23:54:01 -0400
In-Reply-To: <1270518241-13750-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 5 Apr 2010 18:44:01 -0700

> cnic_service_bnx2x() irq handler can be called during chip reset from
> MTU change.  Need to check that the cnic's device state is up before
> handling the irq.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied to net-2.6, thanks.
