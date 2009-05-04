From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" tryingtoifenslave a second interface to my bond
Date: Mon, 04 May 2009 16:00:51 -0700
Message-ID: <15291.1241478051@death.nxdomain.ibm.com>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com> <1241397581.6499.658.camel@homebase.localnet> <4086.1241463817@death.nxdomain.ibm.com> <20090504.120651.32573620.davem@davemloft.net>
Cc: paul@mad-scientist.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:41625 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbZEDXAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 19:00:47 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n44MnjRE020147
	for <netdev@vger.kernel.org>; Mon, 4 May 2009 18:49:45 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n44N0k6O145180
	for <netdev@vger.kernel.org>; Mon, 4 May 2009 19:00:46 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n44N0kPk015979
	for <netdev@vger.kernel.org>; Mon, 4 May 2009 19:00:46 -0400
In-reply-to: <20090504.120651.32573620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Jay Vosburgh <fubar@us.ibm.com>
>Date: Mon, 04 May 2009 12:03:37 -0700
>
>> Paul Smith <paul@mad-scientist.net> wrote:
>> 
>>>Hi Jay/David/etc.;
>>>
>>>This patch is critical for me to properly use mode 6 (balance-alb)
>>>bonding; I assume it will be needed for others as well.  I haven't
>>>checked to see if it's still necessary in 2.6.29/2.6.30, but I didn't
>>>notice it going into the latest 2.6.27.22, released today.
>>>
>>>Is this still unofficial?  Is there an official patch on the horizon?
>> 
>> 	David, please apply and queue for -stable:
>
>Greg just posted that there will be no further 2.6.27.x -stable
>releases after the one he just made.

	Regardless of the -stable situation, the patch is still needed
for the current mainline (sorry if that wasn't clear).  I checked it
against the current net-2.6 and net-next-2.6 trees, and it should apply
to either one.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
