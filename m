From: Daniel Lezcano <dlezcano@meiosys.com>
Subject: Re: [Devel] [PATCH 1/1] Dynamically allocate the loopback device
Date: Fri, 24 Aug 2007 18:44:35 +0200
Message-ID: <46CF0AF3.9080105@meiosys.com>
References: <11879698031215-git-send-email-dlezcano@fr.ibm.com> <46CEFF83.3040003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, davem@davemloft.net,
	shemminger@linux-foundation.org, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: "Denis V. Lunev" <dlunev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:54607 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbXHXQtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 12:49:31 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l7OGnTsA518200
	for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 16:49:29 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7OGnTqI1876112
	for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 18:49:29 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7OGnStw006664
	for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 18:49:29 +0200
In-Reply-To: <46CEFF83.3040003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis V. Lunev wrote:
> dlezcano@fr.ibm.com wrote:
>> From: Daniel Lezcano <dlezcano@fr.ibm.com>
>>
>> Doing this makes loopback.c a better example of how to do a
>> simple network device, and it removes the special case
>> single static allocation of a struct net_device, hopefully
>> making maintenance easier.
>>
>> Applies against net-2.6.24
>>
>> Tested on i386, x86_64
>> Compiled on ia64, sparc
> 
> I think that a small note, that initialization order is changed will be
> good to record. After this, loopback MUST be allocated before any other
> networking subsystem initialization. And this is an important change.
> 
> Regards,
>     Den
> 

Thanks Denis to point that.

	-- Daniel

