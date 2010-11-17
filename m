From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] SELinux: return -ECONNREFUSED from ip_postroute to
 signal fatal error
Date: Wed, 17 Nov 2010 10:55:39 -0800 (PST)
Message-ID: <20101117.105539.28812351.davem@davemloft.net>
References: <20101116215257.6727.12163.stgit@paris.rdu.redhat.com>
	<4CE3BFC4.1010706@trash.net>
	<1290004739.14282.73.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, selinux@tycho.nsa.gov,
	netfilter-devel@vger.kernel.org, equinox@diac24.net,
	eric.dumazet@gmail.com, hzhong@gmail.com, jmorris@namei.org,
	kuznet@ms2.inr.ac.ru, paul.moore@hp.com, pekkas@netcore.fi,
	sds@tycho.nsa.gov, yoshfuji@linux-ipv6.org
To: eparis@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290004739.14282.73.camel@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@redhat.com>
Date: Wed, 17 Nov 2010 09:38:59 -0500

> On Wed, 2010-11-17 at 12:43 +0100, Patrick McHardy wrote:
>> On 16.11.2010 22:52, Eric Paris wrote:
>> > The SELinux netfilter hooks just return NF_DROP if they drop a packet.  We
>> > want to signal that a drop in this hook is a permanant fatal error and is not
>> > transient.  If we do this the error will be passed back up the stack in some
>> > places and applications will get a faster interaction that something went
>> > wrong.
>> 
>> Looks good to me. I'd suggest to have these patches go through Dave's
>> tree since I want to make use of the netfilter error propagation
>> mechanism to return proper errno codes for netfilter re-routing
>> failures.
> 
> 
> I'd be happy if Dave pulled patches 1 and 2.  I can resend patch #3 once
> I can cajole another of the SELinux maintainers to look at it (I believe
> he most likely one is on vacation this week)

I think it's best to pull this all into net-next-2.6 now, so that's what
I'm doing right now.

If there are problems we can apply changes on top.

Thanks.
