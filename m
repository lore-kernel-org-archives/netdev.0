From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net 5/6] net: mvneta: The mvneta_percpu_elect function should be atomic
Date: Mon, 01 Feb 2016 11:22:45 +0100
Message-ID: <87h9hs7mru.fsf@free-electrons.com>
References: <1454084767-24715-1-git-send-email-gregory.clement@free-electrons.com>
	<1454084767-24715-6-git-send-email-gregory.clement@free-electrons.com>
	<20160129.203810.1601035648854177084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, jason@lakedaemon.net,
	andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
	linux-arm-kernel@lists.infradead.org, alior@marvell.com,
	nadavh@marvell.com, mw@semihalf.com, linux@arm.linux.org.uk,
	w@1wt.eu
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160129.203810.1601035648854177084.davem@davemloft.net> (David
	Miller's message of "Fri, 29 Jan 2016 20:38:10 -0800 (PST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,
 
 On sam., janv. 30 2016, David Miller <davem@davemloft.net> wrote:

> From: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Date: Fri, 29 Jan 2016 17:26:06 +0100
>
>> @@ -370,6 +370,8 @@ struct mvneta_port {
>>  	struct net_device *dev;
>>  	struct notifier_block cpu_notifier;
>>  	int rxq_def;
>> +	/* protect  */
>> +	spinlock_t lock;
>>  
>>  	/* Core clock */
>>  	struct clk *clk;
>
> Protect what?  This comment needs a lot of improvement.

Sorry about it, this was a left-over.

>
> Everyone knows a spinlock "protects" things, so if you aren't going
> to actually describe what this lock protects, and in what contexts
> the lock is used, you might as well not say anything at all.

I can only agree with you, I will fix it for next version.

Thanks,

Gregory


-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
