From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] tg3: Add 5785 ASIC revision
Date: Sun, 25 May 2008 23:49:21 -0700 (PDT)
Message-ID: <20080525.234921.226130406.davem@davemloft.net>
References: <1211511428.0@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49389
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751942AbYEZGtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 02:49:25 -0400
In-Reply-To: <1211511428.0@teletran1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 22 May 2008 19:57:08 -0700

> This patch added the 5785 device ID and ASIC revision to the code.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied, although pci_ids.h is pretty much deprecated at this
point and the thing to do is to simply add the raw constant(s)
to the PCI device ID probing tables.
