From: John Haxby <jch@thehaxbys.co.uk>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 19:46:20 +0100
Message-ID: <9A104657-E760-4489-A92E-7DF04CC0EE6C@oracle.com>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com> <4E0115B3.2030802@redhat.com> <20110621225645.GD16021@Chamillionaire.breakpoint.cc> <20110621.155816.1840729860084652508.davem@davemloft.net> <4E01C34F.6050009@redhat.com> <20110622105434.GE16021@Chamillionaire.breakpoint.cc> <4E01E1FD.8010802@oracle.com> <4E0228C3.8090402@redhat.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, fbl@redhat.com,
	netdev@vger.kernel.org, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37873 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758622Ab1FVSqZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 14:46:25 -0400
Received: by wwe5 with SMTP id 5so1147528wwe.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2011 11:46:24 -0700 (PDT)
In-Reply-To: <4E0228C3.8090402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 22 Jun 2011, at 18:39, Prarit Bhargava wrote:

> 
>> Although I wasn't sure that it could happen, it's also possible that the
>> cryptographic functions can get in your way.  xt_SYSRQ does its best to
>> avoid problems by pre-allocating everything it can so there is as little
>> as possible to do when it is needed, but it is possible for it to fail.
>> 
>> 
> 
> My running theory as to the failure is that the CPU that took the sysrq
> is also the CPU that was having problems that resulted in the "slow
> down" of the system.
> 
> On a known-good system, xt_SYSRQ behaves properly AFAICT.  It functions
> exactly the way we want it to.
> 
> So ... I read the following discussion of xt_SYSRQ from last year:
> 
> http://www.kerneltrap.com/mailarchive/linux-netdev/2010/4/21/6275199/thread
> 
> And it seems there were no technical objections to the code, but there
> were other concerns.
> 
> davem -- as I don't monitor this list, are you indicating that you are
> more amenable to this code being accepted upstream?  Or is that part of
> the debate still ongoing?
> 
> 

I've just re-read the thread and I'm reminded that I never did submit the xt_SYSRQ hash update I mentioned at the end of the thread.

davem: I'm more than happy to push that patch through if it will make xt_SYSRQ more acceptable.

jch

