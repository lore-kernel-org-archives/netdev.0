From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/13] tg3: 5784 / 5764 GPHY power down fix
Date: Mon, 12 Nov 2007 21:08:20 -0800 (PST)
Message-ID: <20071112.210820.180509998.davem@davemloft.net>
References: <1194655120.5745.264.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750853AbXKMFIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:08:20 -0500
In-Reply-To: <1194655120.5745.264.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:38:40 -0800

> 5784 and 5764 devices fail to link / pass traffic after one load /
> unload cycle.  This happens because of a hardware bug in the new CPMU.
> During normal operation, the MAC depends on the PHY clock being
> available.  When the PHY is powered down, the clock the MAC depends on
> is disabled.  The fix is to switch the MAC clock to an alternate source
> before powering down the PHY, and to restore the MAC clock to the PHY
> source upon device resume.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Matt.
