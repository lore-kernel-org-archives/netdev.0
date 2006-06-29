From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: TOE, etc.
Date: Thu, 29 Jun 2006 09:09:11 -0500
Message-ID: <1151590151.6424.10.camel@stevo-desktop>
References: <54AD0F12E08D1541B826BE97C98F99F15F5BA4@NT-SJCA-0751.brcm.ad.broadcom.com>
	 <44A3140A.1040901@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Caitlin Bestler <caitlinb@broadcom.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:26887 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1750724AbWF2OJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 10:09:17 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44A3140A.1040901@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> > But back on the main point, if implementing SCSI services over a
> > TCP connection is acceptable even though it does not use a kernel
> > socket, why would it not be acceptable to implement RDMA services
> > over a TCP connection without using a kernel socket?
> 
> Because SCSI doesn't force nasty hooks into the net stack to allow for 
> sharing of resources with a proprietary black box of unknown quality.
> 
> 	Jeff
> 

The netevent notifier patch in question seemed to be reasonable hooks
for notifying kernel and user mode modules of certain network events.
In fact, it went through 3 review cycles and was improved by feedback
from Dave and others.  eg: It was integrated with netlink to provide
user mode notifications.  

Then someone says 'TOE' and suddenly the hooks are nasty?


Steve.

