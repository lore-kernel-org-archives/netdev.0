From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network virtualization/isolation
Date: Mon, 04 Dec 2006 09:52:10 -0700
Message-ID: <m1odqj8uyt.fsf@ebiederm.dsl.xmission.com>
References: <453F8800.9070603@fr.ibm.com> <1165239894.3664.61.camel@localhost>
	<m1k617u10x.fsf@ebiederm.dsl.xmission.com>
	<200612041900.42768.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	devel@openvz.org, Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:45294 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937135AbWLDQxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 11:53:21 -0500
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200612041900.42768.dim@openvz.org> (Dmitry Mishin's message of
	"Mon, 4 Dec 2006 19:00:42 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin <dim@openvz.org> writes:

> On Monday 04 December 2006 18:35, Eric W. Biederman wrote:
> [skip]
>> Where and when you look to find the network namespace that applies to
>> a packet is the primary difference between the OpenVZ L2
>> implementation and my L2 implementation.
>>
>> If there is a better and less intrusive while still being obvious
>> method I am all for it.  I do not like the OpenVZ thing of doing the
>> lookup once and then stashing the value in current and the special
>> casing the exceptions.
> Why?

I like it when things are obvious and not implied.

The implementations seems to favor fewer lines of code touched over
maintainability of the code.  Which if you are maintaining out of
tree code is fine.  At leas that was my impression last time
I looked at the code.

I know there are a lot of silly things in the existing implementations
because they were initially written without the expectation of being
able to merge the code into the main kernel.  This resulted in some
non-general interfaces, and a preference for patches that touch
as few lines of code as possible.  

Anyway this has bit has been discussed before and we can discuss it
seriously in the context of patch review.

Eric
