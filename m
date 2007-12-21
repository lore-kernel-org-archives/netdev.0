From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] XFRM: Drop packets when replay counter would
 overflow
Date: Fri, 21 Dec 2007 14:59:16 -0800 (PST)
Message-ID: <20071221.145916.103462184.davem@davemloft.net>
References: <20071221141334.11660.9191.stgit@flek.lan>
	<20071221141500.11660.12287.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	latten@austin.ibm.com
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42395
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757765AbXLUW7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 17:59:22 -0500
In-Reply-To: <20071221141500.11660.12287.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Fri, 21 Dec 2007 09:15:00 -0500

> According to RFC4303, section 3.3.3 we need to drop outgoing packets which
> cause the replay counter to overflow:
> 
>    3.3.3.  Sequence Number Generation
> 
>    The sender's counter is initialized to 0 when an SA is established.
>    The sender increments the sequence number (or ESN) counter for this
>    SA and inserts the low-order 32 bits of the value into the Sequence
>    Number field.  Thus, the first packet sent using a given SA will
>    contain a sequence number of 1.
> 
>    If anti-replay is enabled (the default), the sender checks to ensure
>    that the counter has not cycled before inserting the new value in the
>    Sequence Number field.  In other words, the sender MUST NOT send a
>    packet on an SA if doing so would cause the sequence number to cycle.
>    An attempt to transmit a packet that would result in sequence number
>    overflow is an auditable event.  The audit log entry for this event
>    SHOULD include the SPI value, current date/time, Source Address,
>    Destination Address, and (in IPv6) the cleartext Flow ID.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied.
