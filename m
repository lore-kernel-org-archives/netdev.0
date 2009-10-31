From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/6] Bonding simplifications and netns support
Date: Fri, 30 Oct 2009 18:45:23 -0700
Message-ID: <6186.1256953523@death.nxdomain.ibm.com>
References: <m1tyxhwxah.fsf@fess.ebiederm.org> <20091030.124153.00934819.davem@davemloft.net> <21200.1256937150@death.nxdomain.ibm.com> <m1639wo5gb.fsf@fess.ebiederm.org> <32609.1256947853@death.nxdomain.ibm.com> <m1ljisid8n.fsf@fess.ebiederm.org>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:45723 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756257AbZJaBp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2009 21:45:26 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9V1bvNi016406
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 21:37:57 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9V1jVVS080712
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 21:45:31 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9ULh0t6017474
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 17:43:01 -0400
In-reply-to: <m1ljisid8n.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:

>Jay Vosburgh <fubar@us.ibm.com> writes:
>
>> 	No, to both questions.  Also, if I back out the 7 bonding
>> patches, the same insmod / rmmod does not panic.  
>>
>> 	I just set it up and did it again.  Fresh boot of the system
>> (which doesn't load bonding); "insmod drivers/net/bonding/bonding.ko;
>> rmmod bonding" and blammo.
>>
>> 	A little bisect action reveals that the problem first appears
>> after applying the fifth patch (below).  Does a basic insmod / rmmod
>> cycle work ok for you?  I'm specifying no options to bonding.
>
>It works here.  The only issue I found was that veth wasn't quite
>working.   I am wondering if there was some version of the tree
>where rtnl_link_unregister is broken and you applied the patches to that.

	Must have been, I did a pull of net-next-2.6 and it seems to
work ok now.  Not sure what it was; I was only a day or so behind.
Anyway, it doesn't panic now; I'll give it some further testing next
week.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
