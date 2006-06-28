From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: TOE, etc.
Date: Wed, 28 Jun 2006 19:43:06 -0400
Message-ID: <44A3140A.1040901@pobox.com>
References: <54AD0F12E08D1541B826BE97C98F99F15F5BA4@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, swise@opengridcomputing.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:61146 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750901AbWF1XnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 19:43:15 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F15F5BA4@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Caitlin Bestler wrote:
> Jeff Garzik wrote:
>> Caitlin Bestler wrote:
>>> But hardware iSCSI implementations, which already exist, do not work
>>> through normal sockets.

>> No, they work through normal SCSI stack...

> Correct.
> 
> But they then interface to the network using none of the network stack.
> The normal SCSI stack does not control that it any way.

Correct.  And the network stack is completely unaware of whatever IP 
addresses, ARP tables, routing tables, etc. it is using.


> NFS over RDMA is part of the file system. That doesn't change the fact
> that it's use of IP Addresses needs to be co-ordinated with the network
> stack, and indeed that address based authentication *assumes* that this
> is the case. (and yes, there are preferable means of authentication, but
> authenticating based on IP address is already supported).

Sounds quite broken to me.


> But back on the main point, if implementing SCSI services over a
> TCP connection is acceptable even though it does not use a kernel
> socket, why would it not be acceptable to implement RDMA services
> over a TCP connection without using a kernel socket?

Because SCSI doesn't force nasty hooks into the net stack to allow for 
sharing of resources with a proprietary black box of unknown quality.

	Jeff


