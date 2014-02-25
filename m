From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: initialize rtl8169_stats seqlock
Date: Mon, 24 Feb 2014 20:32:40 -0500 (EST)
Message-ID: <20140224.203240.898686891281813790.davem@davemloft.net>
References: <20140224231748.GA18598@pd.tnic>
	<20140225011228.GC14970@merlin.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bp@alien8.de, nic_swsd@realtek.com, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kyle@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140225011228.GC14970@merlin.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kyle McMartin <kyle@infradead.org>
Date: Mon, 24 Feb 2014 20:12:28 -0500

> From: Kyle McMartin <kyle@redhat.com>
> 
> Boris reports he's seeing:
>> [    9.195943] INFO: trying to register non-static key.
>> [    9.196031] the code is fine but needs lockdep annotation.
>> [    9.196031] turning off the locking correctness validator.
>> [    9.196031] CPU: 1 PID: 933 Comm: modprobe Not tainted 3.14.0-rc4+ #1
> with the r8169 driver.
> 
> These are occuring because the seqcount embedded in u64_stats_sync on
> 32-bit SMP is uninitialized which is making lockdep unhappy.
> 
> Signed-off-by: Kyle McMartin <kyle@redhat.com>

Good catch, applied, thanks Kyle.
