From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network virtualization/isolation
Date: Mon, 04 Dec 2006 08:45:42 -0700
Message-ID: <m1fybvu0k9.fsf@ebiederm.dsl.xmission.com>
References: <453F8800.9070603@fr.ibm.com> <1165155198.3517.86.camel@localhost>
	<m1y7ppdl50.fsf@ebiederm.dsl.xmission.com>
	<200612041819.01017.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	devel@openvz.org, Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Cedric Goater <clg@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:55067 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937026AbWLDPqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 10:46:34 -0500
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200612041819.01017.dim@openvz.org> (Dmitry Mishin's message of
	"Mon, 4 Dec 2006 18:19:00 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin <dim@openvz.org> writes:

> On Sunday 03 December 2006 19:00, Eric W. Biederman wrote:
>> Ok.  Just a quick summary of where I see the discussion.
>>
>> We all agree that L2 isolation is needed at some point.
> As we all agreed on this, may be it is time to send patches one-by-one?
> For the beggining, I propose to resend Cedric's empty namespace patch as base 
> for others - it is really empty, but necessary in order to move further.
>
> After this patch and the following net namespace unshare patch will be 
> accepted, I could send network devices virtualization patches for review and 
> discussion.
>
> What do you think?

I think sending out these patches for review sounds great.

For merge order I think enabling the unshare/clone flags to anyone
but developers should be about the last thing we do.

Starting with clone/unshare sounds to me like hitching up the cart
before it is built.

I really need to focus on finishing up the pid namespace, so except
for a little review and conversation I'm not going to help much on the
network side.

Of course I need to mess with unix domain sockets to properly
implement the pid namespace.  Because of the pid credential passing.

Eric

