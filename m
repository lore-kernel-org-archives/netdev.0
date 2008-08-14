From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: Add (limited) SYNACK payload support
Date: Wed, 13 Aug 2008 21:02:51 -0700 (PDT)
Message-ID: <20080813.210251.47504019.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069070@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55203
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752316AbYHNECu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 00:02:50 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069070@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Tue, 12 Aug 2008 13:56:47 -0700

> This patch implements the draft spec:
> http://www.ietf.org/internet-drafts/draft-agl-tcpm-sadata-01.txt
> 
> At the moment, this is just an [RFC] patch because an option number hasn't been
> assigned by the IETF yet.
> 
> It allows listening sockets to be configured with a small (<= 64 bytes),
> payload that is included in SYN/ACK packets elicited by SYN packets that
> include a special option. See the draft linked to above for motivations.
> 
> Additionally, the listening socket can request that the kernel replace 8 bytes
> of the payload with random data (that can later be read from the resulting
> accepted socket).

This looks mostly fine to me.  I would even advocate not using a config
option for this.
