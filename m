From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Tue, 04 Mar 2008 15:23:59 -0700
Message-ID: <m1k5ki2kn4.fsf@ebiederm.dsl.xmission.com>
References: <47C6D743.1050802@openvz.org>
	<m1y794514k.fsf@ebiederm.dsl.xmission.com> <47C7B779.808@openvz.org>
	<m1ve453lkp.fsf@ebiederm.dsl.xmission.com>
	<47CBBC61.1010605@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:38380 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655AbYCDWZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:25:38 -0500
In-Reply-To: <47CBBC61.1010605@openvz.org> (Pavel Emelyanov's message of "Mon,
	03 Mar 2008 11:52:49 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@openvz.org> writes:

>> 
>> It takes a little updating of how we use pids.  The easiest method
>> is to add an extra counter.  So we know when someone besides the hash
>> chains is using the pid as an id.  However it might make sense to actually
>> have a net namespace pointer in the pid.
>
> No, please, no. I'm strongly opposed to making pids provide identification
> for anything we need in the kernel.

I don't see the problem.  Sessions and process groups are roughly the
same kinds of concept as namespaces.

However I do agree that not using any kind of id is cleaner, leaves us
with less legacy that we have to deal with, and keeps struct pid
small, so it is preferable.

Eric
