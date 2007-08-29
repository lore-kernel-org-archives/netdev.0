From: Daniel Lezcano <dlezcano@meiosys.com>
Subject: Re: [patch 0/1][RFC] add a private field to the sock structure
Date: Wed, 29 Aug 2007 23:15:31 +0200
Message-ID: <46D5E1F3.4020009@meiosys.com>
References: <20070829164114.868188182@f002726.toulouse-stg.fr.ibm.com> <20070829.112316.98862875.davem@davemloft.net> <20070829191831.GA16184@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>, dlezcano@fr.ibm.com,
	netdev@vger.kernel.org, ralf@linux-mips.org, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:11132 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753712AbXH2VVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 17:21:33 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l7TLLVw6121852
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 21:21:31 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TLLVRI1765570
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 23:21:31 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TLLUXn030978
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 23:21:31 +0200
In-Reply-To: <20070829191831.GA16184@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Wed, Aug 29, 2007 at 11:23:16AM -0700, David Miller escreveu:
>> From: dlezcano@fr.ibm.com
>> Date: Wed, 29 Aug 2007 18:41:14 +0200
>>
>>> When a socket is created it is sometime useful to store a specific information
>>> for this socket.
>>>  
>>> This information can be for examples: 
>>> 	* a creation time
>>> 	* a pid
>>> 	* a uid/gid
>>> 	* a container identifier
>>> 	* a pointer to a more specific structure
>>> 	* ...
>>>
>>> The following patch is a proposition to add a private anonymous pointer
>>> field to the common part of the sock structure.
>> We got rid of the private field a long time ago because not only
>> is it not needed, it tends to get abused.
> 
> Nah, it still there, sk_protinfo, its just ax25 that uses it
> (nudge(Ralf)). How do we state that a struct field is deprecated and
> will be removed soon(tm)?
> 
> There is another, sk_user_data, that is used only by the rpc, pppol2tp,
> iscsi, ncpfs, smbfs and dlm guys, see? We need a deprecate flag for
> sk_protinfo, if not people will use it! :-)

Thank you for your feedbacks. I will play with the sk_user_data.

Is there a chance to have this field in the timewait sockets ? :)

Regards
	--Daniel
