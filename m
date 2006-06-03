From: David Daney <ddaney@avtrex.com>
Subject: Re: RFC3927 ARP patch status?
Date: Fri, 02 Jun 2006 17:58:27 -0700
Message-ID: <4480DEB3.2060806@avtrex.com>
References: <44806926.1050509@avtrex.com> <E1FmIoI-0007nK-00@gondolin.me.apana.org.au> <20060603003955.GJ549@progsoc.uts.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-116-42-147.dsl.sntc01.pacbell.net ([67.116.42.147]:37654
	"EHLO avtrex.com") by vger.kernel.org with ESMTP id S932591AbWFCA62
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 20:58:28 -0400
To: Anand Kumria <wildfire@progsoc.uts.edu.au>
In-Reply-To: <20060603003955.GJ549@progsoc.uts.edu.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anand Kumria wrote:
> Herbert,
> 
> On Sat, Jun 03, 2006 at 09:12:06AM +1000, Herbert Xu wrote:
> 
>>David Daney <ddaney@avtrex.com> wrote:
>>
>>>There were some discussions about whether it made sense for the kernel 
>>>to support the behavior required by the RFC.  Other comments debated the 
>>>wisdom of using a tightly targeted patch specific to the RFC, or whether 
>>>a more general but intrusive solution would be better.
>>
>>I think we've made it quite clear what needs to be done for it to be
>>accepted.  All that remains is for someone to implement it.  If anyone
>>really cares about this, then please write the code instead of talking
>>about it.
> 
> 
> Okay, to confirm: you want a patch which looks at the scope value and if 
> the scope is link-local then we broadcast rather than do a directed ARP?
> 

I don't think that was the plan.  In an earlier e-mail Herbert Xu said 
(and I concur):

------------------------------
I like the idea of allowing user-space to control what addresses cause
broadcasts.  However, I'm uncomfortable with overloading existing flags
even though they might appear to fit the bill on the face of it.

People may be using this for completely different reasons (address
selection) and it's not polite to suddenly turn all their ARPs into
broadcasts.

So how about a new address flag? We still have some vacancies there.
------------------------------

The idea was to add a new flag, *not* reuse the scope value.


David Daney
