From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] tg3: Fix 5714S / 5715S / 5780S link failures
Date: Mon, 09 Jun 2008 15:42:37 -0700 (PDT)
Message-ID: <20080609.154237.227769010.davem@davemloft.net>
References: <1213046675.0@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33833
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763535AbYFIWmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 18:42:38 -0400
In-Reply-To: <1213046675.0@teletran1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 9 Jun 2008 11:25:17 -0700

> The git commit ef167e27039eeaea6d3cdd5c547b082e89840bdd entitled
> "Fix supporting flowctrl code" introduced a bug that prevents 5714S,
> 5715S and 5780S devices from falling back to a forced link mode.  The
> problem is that the added flow control check will always fail if flow
> control is set to autoneg and either RX or TX (or both) flow control
> is enabled.  The driver defaults to setting flow control to autoneg
> and advertises both RX and TX flow control.
> 
> The fix is to remove the errant check.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
