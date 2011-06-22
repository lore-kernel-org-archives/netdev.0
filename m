From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 13:39:15 -0400
Message-ID: <4E0228C3.8090402@redhat.com>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com> <4E0115B3.2030802@redhat.com> <20110621225645.GD16021@Chamillionaire.breakpoint.cc> <20110621.155816.1840729860084652508.davem@davemloft.net> <4E01C34F.6050009@redhat.com> <20110622105434.GE16021@Chamillionaire.breakpoint.cc> <4E01E1FD.8010802@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: John Haxby <john.haxby@oracle.com>,
	Florian Westphal <fw@strlen.de>, fbl@redhat.com,
	netdev@vger.kernel.org, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58730 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757381Ab1FVRjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 13:39:23 -0400
In-Reply-To: <4E01E1FD.8010802@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Although I wasn't sure that it could happen, it's also possible that the
> cryptographic functions can get in your way.  xt_SYSRQ does its best to
> avoid problems by pre-allocating everything it can so there is as little
> as possible to do when it is needed, but it is possible for it to fail.
>
>   

My running theory as to the failure is that the CPU that took the sysrq
is also the CPU that was having problems that resulted in the "slow
down" of the system.

On a known-good system, xt_SYSRQ behaves properly AFAICT.  It functions
exactly the way we want it to.

So ... I read the following discussion of xt_SYSRQ from last year:

http://www.kerneltrap.com/mailarchive/linux-netdev/2010/4/21/6275199/thread

And it seems there were no technical objections to the code, but there
were other concerns.

davem -- as I don't monitor this list, are you indicating that you are
more amenable to this code being accepted upstream?  Or is that part of
the debate still ongoing?

P.
