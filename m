From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Fri, 28 Sep 2007 11:12:13 +0200
Message-ID: <46FCC56D.9050600@fr.ibm.com>
References: <m1tzphrnq5.fsf@ebiederm.dsl.xmission.com> <46FB6F1E.8070105@fr.ibm.com> <m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com> <20070927.124552.69400277.davem@davemloft.net> <m18x6rhfy0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, containers@lists.osdl.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:51439 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757597AbXI1JMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 05:12:18 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8S9CHh4010528
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 05:12:17 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8S9CHYq474882
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 05:12:17 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8S9CGPv031477
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 05:12:17 -0400
In-Reply-To: <m18x6rhfy0.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> David Miller <davem@davemloft.net> writes:
> 
>> Eric, pick an appropriate new non-conflicting number NOW.
> 
> Done.  My apologies for the confusion.  I thought the
> way Cedric and the IBM guys were testing someone would have
> shouted at me long before now.
>
>> This adds unnecessary extra work for Andrew Morton, which he has
>> enough of already.
> 
> Cedric made a good point that we will have conflicts of code
> being added to the same place in nsproxy.c and the like.  So
> I copied Andrew to give him a heads up.

here's a suggestion,

we could keep the net namespace unshare patch out of david's tree,
let andrew merge and release a new -mm and, then, send the net namespace 
unshare patch to andrew. that should keep nsproxy out of the andrew's 
merge challenge. But david's tree will miss the unshare part for a while.

As for the clone flags, the values *must not* conflict but the patches 
probably will.

C.

> I will gladly do what I can, to help.  Working against 3 trees
> development at the moment is a bit of a development challenge.
> 
> Eric
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 

