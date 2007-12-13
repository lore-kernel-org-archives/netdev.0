From: David Miller <davem@davemloft.net>
Subject: Re: reading the tcp headers within the write queue
Date: Thu, 13 Dec 2007 11:00:50 -0800 (PST)
Message-ID: <20071213.110050.104716141.davem@davemloft.net>
References: <20071213185626.GV7409@nuim.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Gavin.McCullagh@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761435AbXLMTAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 14:00:51 -0500
In-Reply-To: <20071213185626.GV7409@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Date: Thu, 13 Dec 2007 18:56:26 +0000

> I'm trying to hack together something which will run through the
> retransmit queue looking at the tcp headers.

The packets in the retransmit queue are headerless, the
header only gets added to clones of the retransmit queue
frames during the actual transmit.

And this question belongs on netdev not linux-net.
