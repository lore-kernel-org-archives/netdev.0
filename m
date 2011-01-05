From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ECN and IP defragmentation
Date: Tue, 04 Jan 2011 18:53:05 -0800 (PST)
Message-ID: <20110104.185305.226784718.davem@davemloft.net>
References: <1294186431.3420.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751047Ab1AECwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 21:52:34 -0500
In-Reply-To: <1294186431.3420.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Jan 2011 01:13:51 +0100

> It seems ip_fragment.c doesnt comply with RFC3168, section 5.3
> 
> 5.3.  Fragmentation
> 
>    ECN-capable packets MAY have the DF (Don't Fragment) bit set.
>    Reassembly of a fragmented packet MUST NOT lose indications of
>    congestion.  In other words, if any fragment of an IP packet to be
>    reassembled has the CE codepoint set, then one of two actions MUST be
>    taken:
> 
>       * Set the CE codepoint on the reassembled packet.  However, this
>         MUST NOT occur if any of the other fragments contributing to
>         this reassembly carries the Not-ECT codepoint.
> 
>       * The packet is dropped, instead of being reassembled, for any
>         other reason.
>
> Should we fix this ?

Definitely, yes.
