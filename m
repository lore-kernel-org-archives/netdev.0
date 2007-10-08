From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4][TG3]: Walk PCI capability lists.
Date: Sun, 07 Oct 2007 23:28:02 -0700 (PDT)
Message-ID: <20071007.232802.112599018.davem@davemloft.net>
References: <1191641822.17453.6.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43362
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751463AbXJHG2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 02:28:03 -0400
In-Reply-To: <1191641822.17453.6.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 05 Oct 2007 20:37:02 -0700

> [TG3]: Walk PCI capability lists.
> 
> Newer tg3 devices shuffle around the registers in PCI configuration
> space.  This patch changes the way the driver accesses the PCI
> capabilities registers.  Hardcoded register locations are replaced with
> offsets from pci_find_capability() return values.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.

This aspect of the driver always bugged me, but if these
capabilities would never move around in PCI config space
I was going to let sleeping dogs lie :-)
