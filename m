From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the permisions of netlink messages
Date: Sat, 24 May 2014 22:45:13 -0700
Message-ID: <87y4xqtnrq.fsf@x220.int.ebiederm.org>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
	<536AB151.2070804@dti2.net>
	<CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
	<20140507.185256.496391962242529591.davem@davemloft.net>
	<CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
	<CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
	<CALCETrVWkW16Y7hOq-mA1auJjRXmwiAUfAGurK0-2bOdbZu_dA@mail.gmail.com>
	<20140522170505.64ef87a2@griffin>
	<87ioow6pt6.fsf@x220.int.ebiederm.org>
	<CA+55aFxybf=ya2RE5nzf10Km+JZ3=HqXGVCHYcteW2EVAUww+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jiri Benc <jbenc@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	David Miller <davem@davemloft.net>,
	"Jorge Boncompte \[DTI2\]" <jorge@dti2.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security\@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:42045 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbaEYFqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 01:46:07 -0400
In-Reply-To: <CA+55aFxybf=ya2RE5nzf10Km+JZ3=HqXGVCHYcteW2EVAUww+g@mail.gmail.com>
	(Linus Torvalds's message of "Fri, 23 May 2014 16:51:17 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Fri, May 23, 2014 at 4:25 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> I have not seen consensus that what Zebra is doing makes sense to
>> support.
>
> Eric, stop right there.
>
> There is no "sensible to support". There is only "reality".
>
> The thing that makes "reality" be "reality" is that it exists whether
> you like it or not, or whether you believe in it or not.
>
> We don't break applications. Whether you like them or not is
> completely immaterial.

You stop right there.  You are shooting the messenger.

I like Zebra just fine, and I hate breaking applications.

We don't retain bug compatibility when the semantics of kernel
interfaces are security vulnerabilities.

I don't appreciate being shot when I am just the messenger saying that
there is not a known fix for Zebra, that it might be unfixable, and that
no one had thought of a anything.

What Andy Lutormiski suggested of checking permissions at connect time
will break a whole lot more than just Zebra.  Unprivileged connect is a
supported feature in netlink, and all information rtnetlink queries
are non-privileged as is listening to rtnetlink brodacsts of network
state chagnes.

In concrete form, no special privileges are requires to run "ip link" or
"ip monitor".  Those among other commands are what Andy has proposed
breaking, all in the name of "supporting" Zebra.

I care just enough I have thrown a patch over the wall and we will see
if it sticks.

Eric
