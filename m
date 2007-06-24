From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sun, 24 Jun 2007 06:38:38 -0600
Message-ID: <m14pkx8r3l.fsf@ebiederm.dsl.xmission.com>
References: <20070623.135737.22037347.davem@davemloft.net>
	<467D9B8F.2050403@garzik.org>
	<m1ejk28eku.fsf@ebiederm.dsl.xmission.com>
	<20070623.224853.12137896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, kaber@trash.net, netdev@vger.kernel.org,
	hadi@cyberus.ca, shemminger@linux-foundation.org,
	greearb@candelatech.com, yoshfuji@linux-ipv6.org,
	containers@lists.osdl.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:56785 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754297AbXFXM5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 08:57:43 -0400
In-Reply-To: <20070623.224853.12137896.davem@davemloft.net> (David Miller's
	message of "Sat, 23 Jun 2007 22:48:53 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Sat, 23 Jun 2007 16:56:49 -0600
>
>> If the only use was strong isolation which Dave complains about I would
>> concur that the namespace approach is inappropriate.  However there are
>> a lot other uses.
>
> By your very admission the only appropriate use case is when users
> are not "hostile" and can be trusted to some extent.

Yes.  Like all of Linux.  Totally hostile antagonistic users that
have millions or billions of dollars to spend better figuring 
out how to mess each other up and do bad things to each other should
not be running code on the same machine.

> And that by definition makes it not appropriate for a general purpose
> operating system like Linux.

Not at all.  The security should be at least as good as between different
users today, and most likely better.

> Containers are I believe a step backwards, and we're better than that.

I heartily disagree.

I do agree that if someone can write a minimal hypervisor it is possible
to provide stronger guarantees of separation on the same hardware then
it is with linux.  But that is because a hypervisor should be such a small
code base one man should be able to prove and audit the thing.  Which allows
several independent people to reproduce that effort.

So my real admission is that hypervisor should be able to do much
stronger isolation.

Namespaces come in when you want to do silly little things like share the
sysadmin responsibility, or not modify applications that make silly assumptions
or don't want to take the huge resource consumption hit hypervisors require.

Eric
