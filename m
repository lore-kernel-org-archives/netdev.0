From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 22:31:43 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0811122213180.1212@ask.diku.dk>
References: <20081112.014923.68124784.davem@davemloft.net>
 <1226487710.6834.53.camel@localhost.localdomain> <20081112.035240.226243372.davem@davemloft.net>
 <20081112.041143.11487260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:57684 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752165AbYKLVbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 16:31:47 -0500
In-Reply-To: <20081112.041143.11487260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Google,

On Wed, 12 Nov 2008, David Miller wrote:

> Guess what that does?  The packet counters live in the upper
> 32-bits and the MARK bits live in the lower 32-bits of the
> TX_CS register.
>
> So it first reads the packet counters, and as a side effect that
> clears the MARK bits in the TX_CS register.  So when we read the lower
> 32-bits the MARK bits are always seen as zero.

For the thorough reader, the TX_CS Transmit Control and Status register is 
described in table 26-15 page 761-762 in the PDF document titled: 
"UltraSPARC T2 supplement to UltraSPARC architecture 2007", downloadable 
from: 
http://opensparc-t2.sunsource.net/specs/UST2-UASuppl-current-draft-HP-EXT.pdf

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
