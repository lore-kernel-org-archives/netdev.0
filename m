From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [RFC] network namespaces
Date: Thu, 17 Aug 2006 12:29:12 +0400
Message-ID: <44E428D8.3050804@sw.ru>
References: <20060815182029.A1685@castle.nmd.msu.ru>	<20060816115313.GC31810@sergelap.austin.ibm.com>	<20060816151226.GA11687@ms2.inr.ac.ru> <m1zme41t3m.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Andrey Savochkin <saw@sw.ru>,
	netdev@vger.kernel.org, dlezcano@fr.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	Andrew Morton <akpm@osdl.org>, devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:44070 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S932319AbWHQI2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 04:28:03 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1zme41t3m.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Basically there are currently 3 approaches that have been proposed.
> 
> The trivial bsdjail style as implemented by Serge and in a slightly
> more sophisticated version in vserver.  This approach as it does not
> touch the packets has little to no packet level overhead.  Basically
> this is what I have called the Level 3 approach.
> 
> The more in depth approach where we modify the packet processing based
> upon which network interface the packet comes in on, and it looks like
> each namespace has it's own instance of the network stack. Roughly
> what was proposed earlier in this thread the Level 2 approach.  This
> potentially has per packet overhead so we need to watch the implementation
> very carefully.
> 
> Some weird hybrid as proposed by Daniel, that I was never clear on the
> semantics.
The good thing is that these approaches do not contradict each other.
We discussed it with Daniel during the summit and as Andrey proposed
some shortcuts can be created to avoid double stack traversing.

>>From the previous conversations my impression was that as long as
> we could get a Layer 2 approach that did not slow down the networking
> stack and was clean, everyone would be happy.
agree.

> I'm buried in the process id namespace at the moment, and except
> to be so for the rest of the month, so I'm not going to be
> very helpful except for a few stray comments.
I will be very much obliged if you find some time to review these new
patches so that we could make some progress here.

Thanks,
Kirill
