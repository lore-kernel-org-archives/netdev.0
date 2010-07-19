From: David Miller <davem@davemloft.net>
Subject: Re: Very low latency TCP for clusters
Date: Mon, 19 Jul 2010 10:35:41 -0700 (PDT)
Message-ID: <20100719.103541.133386663.davem@davemloft.net>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40151
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760573Ab0GSRfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 13:35:25 -0400
In-Reply-To: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 19 Jul 2010 10:05:19 -0700

> Per connection queues (supported by device) should eliminate costs
> of connection look-up, hopefully some locking.

What are these per-connection queues exactly?

Is it like GRO and just accumulates in-order packets for a flow?

Or it is something more like Jacobson's net channels?

If it's the former, we have it already.  If it's the
latter we've found it to be utterly impractical due to all
of the facilities we have which live between the device
and the socket layer (netfilter, packet scheduler, IPSEC,
etc.)
