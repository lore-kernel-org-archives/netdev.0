From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 05/12] net namespace : ioctl to push ifa to net namespace
 l3
Date: Sat, 20 Jan 2007 12:48:27 +0100
Message-ID: <45B2018B.5030807@fr.ibm.com>
References: <20070119154714.439706567@localhost.localdomain> <20070119155351.915374403@localhost.localdomain> <20070120045234.GB6123@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:56459 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965262AbXATLtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jan 2007 06:49:03 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id l0KBmwIQ041126
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 11:48:59 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0KBmtWW3117170
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 12:48:55 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0KBmsTb001121
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 12:48:55 +0100
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20070120045234.GB6123@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl wrote:
> On Fri, Jan 19, 2007 at 04:47:19PM +0100, dlezcano@fr.ibm.com wrote:
>> From: Daniel Lezcano <dlezcano@fr.ibm.com>
>>
>> New ioctl to "push" ifaddr to a container. Actually, the push is done
>> from the current namespace, so the right word is "pull". That will be
>> changed to move ifaddr from l2 network namespace to l3.
>>
>> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
>>

[ ... ]

>> + * namespace to his l2 network namespace parent.
> 
> hmm, sounds like the address is moved between the
> namespaces? does that mean that the 'parent' will
> not see the 'isolated' ip anymore?

Yes, exact. If the IP address is visible into several namespaces (L2 
parent and L3 child), nothing ensures the two will not use the IP address.

