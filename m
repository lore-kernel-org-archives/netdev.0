From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13] tg3: Increase the PCI MRRS
Date: Mon, 12 Nov 2007 21:21:35 -0800 (PST)
Message-ID: <20071112.212135.172019737.davem@davemloft.net>
References: <1194655141.5745.272.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42496
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751710AbXKMFVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:21:36 -0500
In-Reply-To: <1194655141.5745.272.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:39:01 -0800

> Previous devices hardcoded the PCI Maximum Read Request Size to 4K.  To
> better comply with the PCI spec, the hardware now defaults the MRRS to
> 512 bytes.  This will yield poor driver performance if left untouched.
> This patch increases the MRRS to 4K on driver initialization.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

I've applied this patch, but...

I sense that the PCI spec wants devices to use an MRRS value of 512 in
order to get better fairness on a PCI-E segment amongst multiple
devices.

>From that perspective, jacking up the MRRS to 4096 unilaterally seems
like a very bad idea.  If this was necessary for good performance, I'm
sure the PCI spec folks would have choosen a higher value.

Or is this some tg3 specific performance issue?
