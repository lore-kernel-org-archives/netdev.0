From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6/stable] tg3: Restrict phy ioctl access
Date: Thu, 17 Feb 2011 14:11:34 -0800 (PST)
Message-ID: <20110217.141134.115921673.davem@davemloft.net>
References: <1297810270-4690-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45843
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751728Ab1BQWK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:10:58 -0500
In-Reply-To: <1297810270-4690-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Tue, 15 Feb 2011 14:51:10 -0800

> If management firmware is present and the device is down, the firmware
> will assume control of the phy.  If a phy access were allowed from the
> host, it will collide with firmware phy accesses, resulting in
> unpredictable behavior.  This patch fixes the problem by disallowing phy
> accesses during the problematic condition.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Reviewed-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Applied.
