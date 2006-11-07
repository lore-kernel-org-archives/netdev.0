From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 4/4] skge: version 1.9
Date: Tue, 07 Nov 2006 12:28:26 -0800
Message-ID: <200611072028.kA7KSQZt032181@death.nxdomain.ibm.com>
References: <20061005224949.456192755@osdl.org> <20061005225209.769741968@osdl.org> <20061107132506.GS2667@mathom.us>
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:4254 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1753099AbWKGU3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 15:29:11 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kA7KT9OB027535
	for <netdev@vger.kernel.org>; Tue, 7 Nov 2006 15:29:09 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kA7KSWwa099916
	for <netdev@vger.kernel.org>; Tue, 7 Nov 2006 15:28:43 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kA7KSVi8017943
	for <netdev@vger.kernel.org>; Tue, 7 Nov 2006 15:28:32 -0500
To: Michael Stone <mstone@mathom.us>
In-reply-to: <20061107132506.GS2667@mathom.us> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone <mstone@mathom.us> wrote:

>The skge 1.9 patch is looking good on older syskonnect fiber cards.
>Stability issues seem to be taken care of and performance is good. There
>are some strange interactions with bonding, however. If I try to put both
>interfaces of an sk-9844 into a bonded interface, I only see traffic from
>one of them. If I try to config the bonded interface down, the system
>hangs. If I tcpdump either of the individual interfaces (before bonding
>them) I see all the expected traffic.

	Can you provide some bonding configuration details?  Which mode,
options, etc, as well as the relevant bits from dmesg (you can send it
to me privately if it's huge)?  I don't have any skge hardware, so I'm
not able to test this locally.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
