From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.25 1/2]S2io: Fixes to enable multiple transmit fifo
 support
Date: Mon, 17 Dec 2007 22:04:34 -0500
Message-ID: <476738C2.1060905@pobox.com>
References: <1197920149.7518.40.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38538 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936432AbXLRDEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 22:04:41 -0500
In-Reply-To: <1197920149.7518.40.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ramkrishna Vepa wrote:
> Fixes to enable multiple transmit fifos (upto a maximum of eight).
>   - Moved single tx_lock from struct s2io_nic to struct fifo_info.
>   - Moved single ufo_in_band_v structure from struct s2io_nic to struct 
>     fifo_info.
>   - Assign the respective interrupt number for the transmitting fifo in the 
>     transmit descriptor (TXD).
> - Added boundary checks for number of FIFOs enabled and FIFO length.
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

applied 1-2 to #upstream


