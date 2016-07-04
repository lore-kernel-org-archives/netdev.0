From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Mon, 4 Jul 2016 10:24:25 +1000
Message-ID: <20160704002425.GA5153@gwshan>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com>
 <1467586171.7422.104.camel@kernel.crashing.org>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, joel@jms.id.au,
	weixue@trustnetic.com, yuvali@mellanox.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:6895 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932182AbcGDAYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 20:24:34 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u640JJVT141149
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 20:24:33 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23x6hw5g81-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 20:24:33 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 4 Jul 2016 10:24:30 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 64FF62BB0057
	for <netdev@vger.kernel.org>; Mon,  4 Jul 2016 10:24:27 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u640ORRN7274910
	for <netdev@vger.kernel.org>; Mon, 4 Jul 2016 10:24:27 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u640OQSP020326
	for <netdev@vger.kernel.org>; Mon, 4 Jul 2016 10:24:27 +1000
Content-Disposition: inline
In-Reply-To: <1467586171.7422.104.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 04, 2016 at 08:49:31AM +1000, Benjamin Herrenschmidt wrote:
>On Mon, 2016-07-04 at 01:03 +0300, Or Gerlitz wrote:
>> FWIW, talking to a colleague, he made a comment that some of the text
>> above is wrong:
>> 
>> AENs are sent from NIC to BMC. Not from Host to BMC.
>
>Just a typo in the commit message thankfully ;-)
>

Yeah, the AENs are sent from NIC to BMC and the code follows it. The code
is tested on IBM's openPower server where a BMC (ARM system) and host (
Power system and NIC) are included. So the host, the far end and NIC can
be regarded as equivalents.

>> The traffic between a BMC and a NIC is over RBT if it is formatted as
>> NC-SI packets. This is not over network traffic....
>

It's correct. The figure included in the commit log might give the illusion
that NCSI packets are sent over network traffic.

Thanks,
Gavin
