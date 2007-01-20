From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 12/12] net namespace : Add broadcasting
Date: Sat, 20 Jan 2007 12:54:33 +0100
Message-ID: <45B202F9.1050107@fr.ibm.com>
References: <20070119154714.439706567@localhost.localdomain> <20070119155406.351528195@localhost.localdomain> <20070120045837.GD6123@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:31438 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965251AbXATLzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jan 2007 06:55:03 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l0KBt1vn047954
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 11:55:01 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0KBt1hm614506
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 12:55:01 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0KBt18j003286
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 12:55:01 +0100
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20070120045837.GD6123@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl wrote:
> On Fri, Jan 19, 2007 at 04:47:26PM +0100, dlezcano@fr.ibm.com wrote:
>> From: Daniel Lezcano <dlezcano@fr.ibm.com>
>>
>> Broadcast packets should be delivered to l2 and all l3 childs
> 
> hmm, really? shouldn't it only reach those which
> actually have related addresses assigned?

Yes right but this is what happens, My sentence is incomplete.

"broadcast packets should be delivered to l2 and all l3 childs having 
sockets listening for this broadcast address"

Thanks.
