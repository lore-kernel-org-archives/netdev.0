From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44: fix carrier detection on bind
Date: Mon, 11 Oct 2010 15:45:42 -0700 (PDT)
Message-ID: <20101011.154542.226772331.davem@davemloft.net>
References: <1286836950-3161-1-git-send-email-fercerpav@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org, stable@kernel.org
To: fercerpav@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51642
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756941Ab0JKWpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 18:45:21 -0400
In-Reply-To: <1286836950-3161-1-git-send-email-fercerpav@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Fertser <fercerpav@gmail.com>
Date: Tue, 12 Oct 2010 02:42:30 +0400

> For carrier detection to work properly when binding the driver with a cable
> unplugged, netif_carrier_off() should be called after register_netdev(),
> not before.
> 
> Signed-off-by: Paul Fertser <fercerpav@gmail.com>

Applied, thanks.
