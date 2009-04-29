From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: revised locking for x_tables
Date: Tue, 28 Apr 2009 22:37:08 -0700 (PDT)
Message-ID: <20090428.223708.168741998.davem@davemloft.net>
References: <20090428092411.5331c4a1@nehalam>
	<alpine.LFD.2.00.0904280931360.22156@localhost.localdomain>
	<alpine.LFD.2.00.0904280954500.22156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, mathieu.desnoyers@polymtl.ca, mingo@elte.hu,
	dada1@cosmosbay.com, zbr@ioremap.net, peterz@infradead.org,
	jarkao2@gmail.com, paulus@samba.org, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: torvalds@linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904280954500.22156@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 28 Apr 2009 09:55:32 -0700 (PDT)

> On Tue, 28 Apr 2009, Linus Torvalds wrote:
>>
>> Ack. 
>> 
>> It could do with the update from Eric about how non-current CPU writelocks 
>> only require preemp-disable around get_counters() (and then the 
>> local_bh_disable() only around the current-CPU case).
> 
> Btw, regardless, that's an incremental improvement, and does not negate 
> the "Ack" part.

I've applied this, thanks everyone!
