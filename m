From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC 0/5] Containerize syslog
Date: Fri, 07 Dec 2012 10:21:44 -0800
Message-ID: <87ip8dafk7.fsf@xmission.com>
References: <50A9EAD8.9090501@gmail.com> <874nklkjjm.fsf@xmission.com>
	<20121207010355.c809b3f7.akpm@linux-foundation.org>
	<20121207142331.GC4004@sergelap>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Rui Xiang <leo.ruixiang@gmail.com>,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org
To: Serge Hallyn <serge.hallyn@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37118 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284Ab2LGSWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 13:22:06 -0500
In-Reply-To: <20121207142331.GC4004@sergelap> (Serge Hallyn's message of "Fri,
	7 Dec 2012 08:23:31 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Serge Hallyn <serge.hallyn@canonical.com> writes:

> Not as a separate justification admittedly, but the description was
> meant to explain it:  right now /dev/kmsg and sys_syslog are not safe
> and useful in a container;

The user namespace solves this the biggest practical problem, like it
solves so many other problems of excessive privileges in a container.

Since these patches are still mostly in the design
proof-of-concept/design phase I am inclined to see how getting a usable
user namespace affects the situation on the ground.

But I do think there are issues to be solved in some fashion.  We have
the possibiloity of configuring firewall logging rules that are not
usable in containers.   Similarly reasons for mount failures and number
of other cases go silent.

I think it makes some sense to change where we put things in the kernel
log to solve these things but it also makes sense to ask the question
is there a better solution.  Hopefully a little more experience with
these issues and time playing with ideas can make things clear.

Eric
