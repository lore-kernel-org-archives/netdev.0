From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Fri, 28 Sep 2007 22:28:18 +0200
Message-ID: <1191011298.18681.88.camel@chaos>
References: <ygfejgmea00.fsf@janus.isnogud.escape.de>
	 <20070925.140910.41653604.davem@davemloft.net>
	 <1190996839.18681.68.camel@chaos>
	 <20070928.132038.35678834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, kaber@trash.net, joe@perches.com,
	oliver@hartkopp.net, oliver.hartkopp@volkswagen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:57112 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751299AbXI1U2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 16:28:22 -0400
In-Reply-To: <20070928.132038.35678834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-09-28 at 13:20 -0700, David Miller wrote:
> That's not true with CAN.
> 
> With this CAN stuff, any driver you write for it is intimately
> integrated into the design and architecture of the CAN subsystem.  Any
> such driver cannot stand on it's own.  Look at how these drivers can
> get into the internals.

I'm just concerned about protocols, which have been designed and
implemented long ago outside of the kernel and are going to be wrapped
with glue code to fit into the socket can implementation. That's hard to
judge.

> If this code goes in without the _GPL() exports, that's fine, but it's
> setting incorrect expectations for people who think they can write
> binary-only drivers and link to these symbols.
> 
> And it will be the CAN folks who are guilty of setting these
> false premises.  Especially after I've explicitly warned about
> it here.

Fair enough.

	tglx


