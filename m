From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7][TG3]: Use msleep.
Date: Thu, 07 Dec 2006 00:23:48 -0800 (PST)
Message-ID: <20061207.002348.34742872.davem@davemloft.net>
References: <1165477637.8488.32.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42648
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031849AbWLGIXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 03:23:36 -0500
To: mchan@broadcom.com
In-Reply-To: <1165477637.8488.32.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 06 Dec 2006 23:47:17 -0800

> [TG3]: Use msleep.
> 
> Change some udelay() in some eeprom functions to msleep().  Eeprom
> related functions are always called from sleepable context.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.

Thanks for continuing to work on eliminating these long
udelay()s.
