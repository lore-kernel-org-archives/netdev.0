From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Mon, 26 Jan 2009 15:19:18 -0800
Message-ID: <497E44F6.2010703@hp.com>
References: <497E361B.30909@hp.com> <497E42F4.7080201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497E42F4.7080201@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Hi Rick, nice hardware you have :)

Every once in a while the cobbler's children get some shoes to wear :)

> 
> Stephen had a patch to nuke read_lock() from iptables, using RCU and seqlocks.
> I hit this contention point even with low cost hardware, and quite standard application.
> 
> I pinged him few days ago to try to finish the job with him, but it seems Stephen
> is busy at the moment.
> 
> Then conntrack (tcp sessions) is awfull, since it uses a single rwlock_t tcp_lock
>  that must be write_locked() for basically every handled tcp frame...
> 
> How long is "not indefinitely" ? 

The system I am using is being borrowed under an open ended loan.  However, my 
use of it can be thought of as being the "null process" in VMS - once anyone else 
wants it I have to get off of it.

That said, I would guess that the chances of someone else trying to get that 
system are pretty small for the next four+ weeks.  I had a similar system (PCIe 
I/O rather than PCI-X) for quite a few weeks before it got pulled-out from under.

rick
