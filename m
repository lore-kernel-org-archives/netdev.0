From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: TOE, etc.
Date: Wed, 28 Jun 2006 14:15:45 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F15F5BA4@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, swise@opengridcomputing.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:10502 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751545AbWF1VTs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 17:19:48 -0400
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Caitlin Bestler wrote:
>> netdev-owner@vger.kernel.org wrote:
>>> From: Steve Wise <swise@opengridcomputing.com>
>>> Date: Wed, 28 Jun 2006 09:54:57 -0500
>>> 
>>>> Doesn't iSCSI have this same issue?
>>> Software iSCSI implementations don't have the issue because they go
>>> through the stack using normal sockets and normal device send and
>>> receive.
>> 
>> But hardware iSCSI implementations, which already exist, do not work
>> through normal sockets.
> 
> No, they work through normal SCSI stack...
> 
> 	Jeff

Correct.

But they then interface to the network using none of the network stack.
The normal SCSI stack does not control that it any way.

NFS over RDMA is part of the file system. That doesn't change the fact
that it's use of IP Addresses needs to be co-ordinated with the network
stack, and indeed that address based authentication *assumes* that this
is the case. (and yes, there are preferable means of authentication, but
authenticating based on IP address is already supported).

But back on the main point, if implementing SCSI services over a
TCP connection is acceptable even though it does not use a kernel
socket, why would it not be acceptable to implement RDMA services
over a TCP connection without using a kernel socket?

