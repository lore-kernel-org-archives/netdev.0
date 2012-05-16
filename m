From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] netfilter fixes for 3.4-rc7
Date: Wed, 16 May 2012 15:39:13 -0400 (EDT)
Message-ID: <20120516.153913.686915759183202821.davem@davemloft.net>
References: <alpine.DEB.2.00.1205162037110.2742@blackhole.kfki.hu>
	<20120516.151836.786389543745557157.davem@davemloft.net>
	<alpine.DEB.2.00.1205162130090.2742@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: kadlec@blackhole.kfki.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1205162130090.2742@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date: Wed, 16 May 2012 21:34:55 +0200 (CEST)

> On Wed, 16 May 2012, David Miller wrote:
> 
>> > Could at least the patch with the subject
>> > 
>> >    netfilter: ipset: fix hash size checking in kernel
>> > 
>> >    The hash size must fit both into u32 (jhash) and the max value of
>> >    size_t. The missing checking could lead to kernel crash, bug reported
>> >    by Seblu.
>> > 
>> > be submitted into 3.4-rc7? Any non most-recent ipset package compiled with 
>> > gcc-4.7 or above can trigger the bug.
>> 
>> And only root can trigger it if he gives bogus parameters right?
> 
> Yes, root can trigger it only, however it's a two sided bug: ipset < 6.12 
> compiled with gcc >= 4.7 is broken and sends bogus data to the kernel, 
> even when normal input parameters are supplied. And unpatched kernel can 
> crash when acting on the bogus data. :-(

Ok, that's a more convincing argument.

I've applied the hash size validation patch to 'net'.
