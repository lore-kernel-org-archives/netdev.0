From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/13] tg3: Prescaler fix
Date: Mon, 12 Nov 2007 21:18:41 -0800 (PST)
Message-ID: <20071112.211841.238922018.davem@davemloft.net>
References: <1194655139.5745.271.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42491
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751554AbXKMFSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:18:42 -0500
In-Reply-To: <1194655139.5745.271.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:38:59 -0800

> Internal hardware timers become inaccurate after link events.  Clock
> frequency switches performed by the CPMU fail to adjust timer
> prescalers.  The fix is to detect core clock frequency changes during
> link events and adjust the timer prescalers accordingly.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

This CPMU seems very sensitive in it's MAC/PHY interactions.
:-)

Patch applied, thanks!
