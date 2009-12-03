From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] bnx2: Print warning when unable to allocate the
 full SKB/page ring.
Date: Thu, 03 Dec 2009 13:08:21 -0800 (PST)
Message-ID: <20091203.130821.253017587.davem@davemloft.net>
References: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
	<1259869595-6450-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752727AbZLCVIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:08:15 -0500
In-Reply-To: <1259869595-6450-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 3 Dec 2009 11:46:33 -0800

> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied, but I would rate limit this thing.

It could especially be problematic if this condition is
triggered when the device is being used for netconsole.
