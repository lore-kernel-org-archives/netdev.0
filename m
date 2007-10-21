From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] tg3: MII => TP
Date: Sun, 21 Oct 2007 16:14:42 -0700 (PDT)
Message-ID: <20071021.161442.22476508.davem@davemloft.net>
References: <1192829803.22064.556.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751120AbXJUXO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 19:14:29 -0400
In-Reply-To: <1192829803.22064.556.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 19 Oct 2007 14:36:42 -0700

> This patch changes the PHY type reported through ethtool for copper
> devices from MII to TP.  The latter is more accurate.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

You should set both MII and TP, since these copper interfaces
have a MII based twisted-pair physical layer.
