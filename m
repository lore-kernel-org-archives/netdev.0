From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: Re: reading the tcp headers within the write queue
Date: Thu, 13 Dec 2007 19:08:59 +0000
Message-ID: <20071213190859.GW7409@nuim.ie>
References: <20071213185626.GV7409@nuim.ie>
 <20071213.110050.104716141.davem@davemloft.net>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:60588 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754414AbXLMTIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 14:08:55 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JT0002H056SGY80@mango.nuim.ie> for
 netdev@vger.kernel.org; Thu, 13 Dec 2007 19:08:52 +0000 (GMT)
In-reply-to: <20071213.110050.104716141.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

thanks for the swift reply.

On Thu, 13 Dec 2007, David Miller wrote:

> > I'm trying to hack together something which will run through the
> > retransmit queue looking at the tcp headers.
> 
> The packets in the retransmit queue are headerless, the
> header only gets added to clones of the retransmit queue
> frames during the actual transmit.

Thought that might be it. I presume there isn't any other residue of the
tcp options elsewhere, that one could look at when the packet gets
acknowledged?  I'm particularly interested in the timestamp.

> And this question belongs on netdev not linux-net.

Oops, sorry.

Gavin

