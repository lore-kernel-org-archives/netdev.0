From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next v2] net/faraday: Disallow using reversed MAC
 address from hardware
Date: Fri, 22 Jul 2016 10:01:48 +1000
Message-ID: <20160722000148.GA5176@gwshan>
References: <1469065374-9916-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <20160721140109.GM11309@lunn.ch>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, benh@kernel.crashing.org,
	David.Laight@ACULAB.COM
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:45474 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751637AbcGVAB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 20:01:57 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6LNx1kN018510
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 20:01:57 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24athde5pv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 20:01:56 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 22 Jul 2016 10:01:54 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 441AC3578052
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 10:01:51 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6M01psg22609986
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 10:01:51 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6M01oX3003573
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 10:01:50 +1000
Content-Disposition: inline
In-Reply-To: <20160721140109.GM11309@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 04:01:09PM +0200, Andrew Lunn wrote:
>On Thu, Jul 21, 2016 at 11:42:54AM +1000, Gavin Shan wrote:
>> The initial MAC address is retrieved from hardware if it's not
>> provided by device-tree. The reserved MAC address from hardware
>> will be used if non-reserved MAC address is invalid. It will
>> cause mismatched MAC address seen by hardware and software.
>> 
>> This disallows using the reserved hardware MAC address to avoid
>> the mismatched MAC address seen by hardware and software.
>> 
>> Fixes: 113ce107afe9 ("net/faraday: Read MAC address from chip")
>> Suggested-by: David Laight <David.Laight@ACULAB.COM>
>> Suggested-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>
>Too late now, since it has been accepted, but the subject line says
>reversed, not reserved.
>

Yes, It should be reversed, not reserved in the commit log.

Thanks,
Gavin
