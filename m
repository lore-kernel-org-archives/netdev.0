From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] [IrDA] Race between open and disconnect in irda-usb
Date: Sun, 16 Dec 2007 14:07:48 -0800 (PST)
Message-ID: <20071216.140748.220124991.davem@davemloft.net>
References: <20071216234648.774780960@sortiz.org>
	<20071216234932.929834588@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	oneukum@suse.de
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760015AbXLPWH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 17:07:57 -0500
In-Reply-To: <20071216234932.929834588@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Ortiz <samuel@sortiz.org>
Date: Mon, 17 Dec 2007 00:46:49 +0100

> It seems to me that irda_usb_net_open() must set self->netopen
> under spinlock or disconnect() may fail to kill all URBs, if it is called
> while an interface is opened.
> 
> From: Oliver Neukum <oneukum@suse.de>
> Signed-off-by: Oliver Neukum <oneukum@suse.de>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied, thanks.
