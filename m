From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] vxge: use pci_request_region()
Date: Fri, 10 Dec 2010 16:09:04 -0800 (PST)
Message-ID: <20101210.160904.137847015.davem@davemloft.net>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
	<1292025782-16372-3-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, ram.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53868
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757257Ab0LKAIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:08:36 -0500
In-Reply-To: <1292025782-16372-3-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Fri, 10 Dec 2010 18:02:58 -0600

> Only BAR0 is ever accessed, thus making the calls to pci_request_regions
> overkill.  Change calls of pci_request_regions to pci_request_region to
> reduce the size of the mapped area.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>
> Signed-off-by: Ram Vepa <ram.vepa@exar.com>

Applied.
