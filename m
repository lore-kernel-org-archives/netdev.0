From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 12 May 2009 18:11:50 +0200
Message-ID: <87octymhbt.fsf@basil.nowhere.org>
References: <1242076914.12380.2.camel@bender>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Christoph Lameter <cl@linux.com>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52160 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbZELQLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 12:11:54 -0400
In-Reply-To: <1242076914.12380.2.camel@bender> (Johann Baudy's message of "Mon, 11 May 2009 23:21:54 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johann Baudy <johann.baudy@gnu-log.net> writes:

> From: Johann Baudy <johann.baudy@gnu-log.net>
>
> New packet socket feature that makes packet socket more efficient for transmission.
> - It reduces number of system call through a PACKET_TX_RING mechanism, based on PACKET_RX_RING (Circular buffer allocated in kernel space which is mmapped from user space).
> - It minimizes CPU copy using fragmented SKB (almost zero copy).

When you add new interfaces like this you should add them to the packet (7)
manpage too.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
