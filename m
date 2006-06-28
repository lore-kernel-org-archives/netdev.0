From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: TOE, etc.
Date: Wed, 28 Jun 2006 16:54:03 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F15F5BDE@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, swise@opengridcomputing.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:49924 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1750889AbWF1XzR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 19:55:17 -0400
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Caitlin Bestler wrote:
>> Jeff Garzik wrote:
>>> Caitlin Bestler wrote:
>>>> But hardware iSCSI implementations, which already exist, do not
>>>> work through normal sockets.
> 
>>> No, they work through normal SCSI stack...
> 
>> Correct.
>> 
>> But they then interface to the network using none of the network
>> stack. The normal SCSI stack does not control that it any way.
> 
> Correct.  And the network stack is completely unaware of
> whatever IP addresses, ARP tables, routing tables, etc. it is using.
> 
> 
>> NFS over RDMA is part of the file system. That doesn't change the
>> fact that it's use of IP Addresses needs to be co-ordinated with the
>> network stack, and indeed that address based authentication
>> *assumes* that this is the case. (and yes, there are preferable
>> means of authentication, but authenticating based on IP address is
>> already supported). 
> 
> Sounds quite broken to me.
> 
> 
>> But back on the main point, if implementing SCSI services over a
>> TCP connection is acceptable even though it does not use a kernel
>> socket, why would it not be acceptable to implement RDMA services
>> over a TCP connection without using a kernel socket?
> 
> Because SCSI doesn't force nasty hooks into the net stack to
> allow for
> sharing of resources with a proprietary black box of unknown quality.
> 
> 	Jeff

RDMA can also solve all of these problems on its own. Complete with
giving the network administrator *no* conventional controls over the
IP address being used for RDMA services.

That means no standard ability to monitor connections, no standard
ability to control which connections are made with whom.

That is better? 

You seem to be practically demanding that RDMA build an entire
parallel stack.

Worse, that *each* RDMA vendor build an entire parallel stack.

Open source being what it is, that is not terribly difficult.
But exactly how does this benefit Linux users?

The proposed subscriptions are not about sharing *resources*, they
share *information* with device drivers. The quality of each
RDMA device driver will be just as known as for a SCSI driver,
an InfiniBand HCA driver, a graphics driver or a plain Ethernet
driver.



