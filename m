From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Tue, 09 Oct 2007 15:00:10 -0600
Message-ID: <m1tzp0vw9x.fsf@ebiederm.dsl.xmission.com>
References: <OF54650AF1.A1051792-ON8825736F.00588F0B-8825736F.00597D24@us.ibm.com>
	<m1k5pwxjxd.fsf@ebiederm.dsl.xmission.com>
	<20071009.131113.112622864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, xemul@openvz.org, devel@openvz.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:53790 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681AbXJIVFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 17:05:06 -0400
In-Reply-To: <20071009.131113.112622864.davem@davemloft.net> (David Miller's
	message of "Tue, 09 Oct 2007 13:11:13 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 09 Oct 2007 11:43:58 -0600
>
>> David Stevens <dlstevens@us.ibm.com> writes:
>> 
>> > Sorry if this is a dumb question, but what is the model you intend for
>> > SNMP? Do you want each namespace to be its own virtual machine with
>> > its own, separate MIB?
>> 
>> Each network namespace appears to user space as a completely separate
>> network stack.  So yes a separate instance of the MIB is appropriate.
>
> We don't think you can validly do that, as David tried to explain.
>
> The interface indexes are visible remotely to remote SNMP querying
> applications.  They have to be unique within the physical system.

I think figuring out what we are doing with SNMP is not any harder
or easier then any other user space interface, and like I said I
don't think we are ready yet.

>From the perspective of monitoring network namespaces make the entire
system looks more like a cluster then it does a single machine, and
that is how I would look at portraying the system to SNMP if I had to
do that work today.  A switch with a bunch of different machines 
behind it.  Especially in the context of container migration this
becomes an attractive model.

Regardless it is early yet and there is plenty of time to revisit this
after we solved the easier and less controversial problems.

Eric
