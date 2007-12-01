From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] sky2: align IP header on Rx if possible
Date: Sat, 01 Dec 2007 16:53:53 -0500
Message-ID: <4751D7F1.3030907@pobox.com>
References: <20071128142703.7f0b5e5d@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47720 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751358AbXLAVxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:53:55 -0500
In-Reply-To: <20071128142703.7f0b5e5d@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> The sky2 driver was not aligning the IP header on receive buffers.
> This workaround is only needed on hardware with broken FIFO, newer chips
> without FIFO can just DMA to unaligned address.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied 1-2


