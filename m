From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 0/6] Various NetLabel fixes and cleanups
Date: Wed, 30 Aug 2006 09:18:26 -0400
Message-ID: <44F59022.30907@hp.com>
References: <20060829144251.452774000@hp.com> <20060829.175644.66176288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:61875 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1751024AbWH3NSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 09:18:31 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060829.175644.66176288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: paul.moore@hp.com
> Date: Tue, 29 Aug 2006 10:42:51 -0400
> 
> 
>>This patchset contains a series of small patches to fix a bug and some general
>>ugliness from the original author (that moron ...).  All of the following
>>patches are against David's net-2.6.19 tree.
>>
>>Please consider these for 2.6.19, thanks.
> 
> Applied to net-2.6.19, thanks a lot Paul.

No problem.

> Does the bug fix in that first patch fix the ssh problem?

As far as the kernel is concerned, yes.  There was a problem in the
kernel of the sk_security_struct->sclass variable not being initialized
correctly which the posted patch fixes as well as a problem with the ssh
daemon rejecting all connections with IP options.  Looking at the ssh
code it appears that they wanted to reject source routed connections but
they were a bit heavy handed and simply rejected connections if any
options were present.

There is more information in this Fedora Bugzilla:

 * https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=202856

-- 
paul moore
linux security @ hp
