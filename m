From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/15] tg3: Preserve LAA when device control is released
Date: Mon, 03 Nov 2008 16:51:52 -0800 (PST)
Message-ID: <20081103.165152.206449779.davem@davemloft.net>
References: <1225751620.6175@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38252
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753156AbYKDAwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 19:52:16 -0500
In-Reply-To: <1225751620.6175@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 3 Nov 2008 02:11:19 -0800

> This patch moves the __tg3_set_mac_addr() function earlier in the file
> listing, to avoid a function prototype, and calls the function to
> restore the LAA after a driver unload chip reset.  With this code in
> place, the administrator can wake the machine using the LAA.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
