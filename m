From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Fri, 20 Oct 2006 12:53:02 -0700
Message-ID: <200610201953.k9KJr2Zt000305@death.nxdomain.ibm.com>
References: <200610162021.12884.dpc@asn.pl> <200610171016.21964.dpc@asn.pl> <20061019190407.GA23446@gospo.rdu.redhat.com> <200610202141.15140.dpc@asn.pl>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:51886 "EHLO e6.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1946178AbWJTTxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 15:53:06 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9KJrJXG031940
	for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 15:53:19 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9KJr5Ar143392
	for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 15:53:05 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9KJr4JJ023590
	for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 15:53:05 -0400
To: Dawid Ciezarkiewicz <dpc@asn.pl>
In-reply-to: <200610202141.15140.dpc@asn.pl> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dawid Ciezarkiewicz <dpc@asn.pl> wrote:

>On Thursday, 19 October 2006 21:04, Andy Gospodarek wrote:
>> It would seem to me that extending an existing mode would be more
>> desirable than adding yet another mode to worry about.  I don't even
>> like the fact that there are as many as there are, but I understand why
>> they are there.  
>
>Ack. I will probably update wrr bonding patch to replace rr mode.

	Also, if acceptance into the mainline is your ultimate goal, the
ioctl control interface will be a very difficult sell.  You'd want to
look into some other control mechanism, most likely an additional sysfs
entry.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
