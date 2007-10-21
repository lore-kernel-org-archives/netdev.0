From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] tg3: PCI command adjustment
Date: Sun, 21 Oct 2007 16:17:36 -0700 (PDT)
Message-ID: <20071021.161736.43033261.davem@davemloft.net>
References: <1192829814.22064.558.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43388
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750757AbXJUXRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 19:17:22 -0400
In-Reply-To: <1192829814.22064.558.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 19 Oct 2007 14:36:53 -0700

> This patch changes the way the driver works with the PCI command
> register.  It adjusts the access size from dwords to words.  This patch
> is done both as a PCI configuration space cleanup and as preparatory
> work for PCI error recovery.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

I will apply this patch but I can imagine this 32-bit store
did things for us that will no longer be done.

For example, it might have been clearing error indications
in the PCI_STATUS reguster.
