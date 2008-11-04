From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/15] tg3: Use pci_ioremap_bar()
Date: Mon, 03 Nov 2008 16:50:46 -0800 (PST)
Message-ID: <20081103.165046.71461900.davem@davemloft.net>
References: <1225751618.6169@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38244
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752918AbYKDAvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 19:51:11 -0500
In-Reply-To: <1225751618.6169@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 3 Nov 2008 02:10:35 -0800

> This patch replaces the existing APE register mapping code with a call
> to pci_ioremap_bar().  The code that maps the main device register space
> did not undergo a similar change because the information derived from
> the pci_resource_start() and pci_resource_len() is still used to
> populate the (optional) mem_start and mem_end netdevice members.
> Replace hardcoded constants where appropriate.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, but I think you can simply just remove those
dev->mem_start and dev->mem_end settings, they are
completely useles and if that is the only thing blocking
universal use of pci_ioremap_bar() it is yet another
reason to remove them.
