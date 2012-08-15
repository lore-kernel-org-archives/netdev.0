From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 0/21] User namespace changes to the networking stack.
Date: Tue, 14 Aug 2012 17:47:15 -0700
Message-ID: <87k3x1htgs.fsf@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<20120814.171203.1784557890475348401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	serge@hallyn.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35104 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab2HOArX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 20:47:23 -0400
In-Reply-To: <20120814.171203.1784557890475348401.davem@davemloft.net> (David
	Miller's message of "Tue, 14 Aug 2012 17:12:03 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 13 Aug 2012 13:07:10 -0700
>
>> 
>> This is a modest set of changes against the current networking stack to
>> enable basic user namespace support.  Allowing the code to compile with
>> user namespaces enabled and removing the assumption that there is only
>> the initial user namespace.
>> 
>> Work to relax the privilege checks in the networking stack from
>> "capable(CAP_NET_ADMIN)" or "capable(CAP_NET_RAW)" to
>> "ns_capable(net->user_ns, CAP_NET_ADMIN)" or 
>> "ns_capable(net->user_ns, CAP_NET_RAW)" allowing root in a user
>> namespace to control a network namespace will come later.
>> 
>> David there are just enough interdependencies between the user namespace
>> bits that I intend to merge them all through my user namespace tree.
>> After the review is complete I will add these patches to my for-next
>> branch of my user-namespace.git tree where I do not intend to rebase.
>> If it make sense to pull these into net-next to avoid or reduce
>> conflicts that should not be a problem.
>
> Looks fine to me, you can add:
>
> Acked-by: David S. Miller <davem@davemloft.net>
>
> to all of this stuff.  Let me know when something is stable in your
> tree, and I can therefore pull from it into net-next.

Will do.  It doesn't look like anyone has any problems with this stuff,
so that should be shortly.

Eric
