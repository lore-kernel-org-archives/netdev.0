From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-2.6.24][patch 2/2] Dynamically allocate the loopback device
Date: Mon, 17 Sep 2007 20:44:14 -0600
Message-ID: <m1r6kwpu9t.fsf@ebiederm.dsl.xmission.com>
References: <20070917101314.5d1673da@freepuppy.rosehill.hemminger.net>
	<46EECCD5.5090601@fr.ibm.com>
	<224b7d320709171212o66734847kbd17efa817b482fc@mail.gmail.com>
	<20070917.185349.98863851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pjwaskiewicz@gmail.com, dlezcano@fr.ibm.com,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.osdl.org, benjamin.thery@bull.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:58526 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbXIRCpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 22:45:22 -0400
In-Reply-To: <20070917.185349.98863851.davem@davemloft.net> (David Miller's
	message of "Mon, 17 Sep 2007 18:53:49 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: "Peter Waskiewicz" <pjwaskiewicz@gmail.com>
> Date: Mon, 17 Sep 2007 12:12:24 -0700
>
>> This would be a good opportunity to remove the single-allocated queue struct
>> in netdevice (at the bottom) that we had to put in to accomodate the static
>> loopback.  Now we can set it back to a zero element list, and have
>> alloc_netdev_mq() just allocate the number of queues requested, not
>> num_queues - 1.
>> 
>> I'll put a patch together based on this patchset.
>
> Thanks Peter.
>
> I'll also let this sit so that Eric can provide any feedback
> he wants and also figure out how he will use this for the
> namespace stuff.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
Not that it doesn't already have my signed off by.

I have an earlier version of this patch sitting in my tree,
along with some additional patches to make this per namespace.

I don't really care which version of this patch goes in and
I'm happy to give Daniel credit for doing the final work to get this
patch merged.

I think it is important for bisect reasons that we first dynamically
allocate the loopback device and then make it per network namespace.
So someone can determine which part of the work caused a problem if
there is one.

Eric

