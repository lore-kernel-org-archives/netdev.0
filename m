From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to specifiy
 the time of TIME-WAIT
Date: Fri, 28 Sep 2012 10:30:27 -0700
Message-ID: <5065DEB3.3040508@hp.com>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com> <20120927142334.GA3194@neilslaptop.think-freely.org> <1348813987.7264.41.camel@cr0> <20120928.024336.598451765169362800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, kaber@trash.net, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:45491 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758326Ab2I1Rae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 13:30:34 -0400
In-Reply-To: <20120928.024336.598451765169362800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2012 11:43 PM, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Fri, 28 Sep 2012 14:33:07 +0800
>
>> I don't think reducing TIME_WAIT is a good idea either, but there must
>> be some reason behind as several UNIX provides a microsecond-scale
>> tuning interface, or maybe in non-recycle mode, their RTO is much less
>> than 2*MSL?

Microsecond?  HP-UX uses milliseconds for the units of the tunable, 
though that does not necessarily mean it will actually be implemented to 
millisecond accuracy

> Yes, there is a reason.  It's there for retaining multi-million-dollar
> customers.
>
> There is no other reasons these other systems provide these
> facilities, they are simply there in an attempt to retain a dwindling
> customer base.
 >
 > Any other belief is extremely naive.

HP-UX's TIME_WAIT interval tunability goes back to HP-UX 11.0, which 
first shipped in 1997.  It got it by virtue of using a "Mentat-based" 
stack which had that functionality.  I may not have my history 
completely correct, but Solaris 2 also got their networking bits from 
Mentat, and I believe shipped before HP-UX 11.

To my recollection, neither were faced with a dwindling customer base at 
the time.

rick jones
