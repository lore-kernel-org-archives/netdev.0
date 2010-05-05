From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 1/3] bnx2: Add GRO support.
Date: Wed, 05 May 2010 00:49:11 -0700 (PDT)
Message-ID: <20100505.004911.183056893.davem@davemloft.net>
References: <1273036906-29162-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56328
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752684Ab0EEHtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 03:49:07 -0400
In-Reply-To: <1273036906-29162-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 4 May 2010 22:21:44 -0700

> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Please turn it on by default by setting NETIF_F_GRO in your probe
routine.

I don't want a precedent started where we have drivers that support
GRO but don't enable it by default.  If there are some performance
degradations, we fix them instead of deferring the issue by not
enabling it by default in some awkward selection of drivers.
