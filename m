From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: add quirk to limit DMA
Date: Tue, 05 Oct 2010 00:18:00 -0700 (PDT)
Message-ID: <20101005.001800.13732127.davem@davemloft.net>
References: <20100929092515.GA6804@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	luya@fedoraproject.org
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45949
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757651Ab0JEHRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 03:17:39 -0400
In-Reply-To: <20100929092515.GA6804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Wed, 29 Sep 2010 11:33:23 +0200

> Skge devices installed on some Gigabyte motherboards are not able to
> perform 64 dma correctly due to board PCI implementation, so limit
> DMA to 32bit if such boards are detected.
> 
> Bug was reported here:
> https://bugzilla.redhat.com/show_bug.cgi?id=447489
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Tested-by: Luya Tshimbalanga <luya@fedoraproject.org>

Stephen?  Can I get an ACK or some kind of other status on this?
