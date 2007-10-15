From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tehuti: possible leak in bdx_probe
Date: Mon, 15 Oct 2007 14:34:00 -0400
Message-ID: <4713B298.2030709@garzik.org>
References: <4710FA6A.2070902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: baum@tehutinetworks.net, andy@greyhouse.net,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Florin Malita <fmalita@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53618 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933922AbXJOSeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 14:34:17 -0400
In-Reply-To: <4710FA6A.2070902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florin Malita wrote:
> If pci_enable_device fails, bdx_probe returns without freeing the 
> allocated pci_nic structure.
> 
> Coverity CID 1908.
> 
> Signed-off-by: Florin Malita <fmalita@gmail.com>
> ---
> 
> drivers/net/tehuti.c |    3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)

applied


