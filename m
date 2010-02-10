From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] net: simplify seq_file code, revised
Date: Wed, 10 Feb 2010 12:29:47 -0800 (PST)
Message-ID: <20100210.122947.171052717.davem@davemloft.net>
References: <4B712849.9040400@cn.fujitsu.com>
	<20100210.113115.28754681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: lizf@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100210.113115.28754681.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 10 Feb 2010 11:31:15 -0800 (PST)

> From: Li Zefan <lizf@cn.fujitsu.com>
> Date: Tue, 09 Feb 2010 17:18:01 +0800
> 
>> This patchset introduces seq_hlist_foo() helpers, and convert
>> net/* to seq_hlist_foo() and seq_list_foo().
>> 
>> Changelog:
>> 
>> - Add kerneldoc in patch 1/13
>> - Fix compile warning in patch 11/13
>> - Fix a bug in patch 12/13
> 
> All applied to net-next-2.6, thanks!

You did not build test your changes.

net/irda/irlan/irlan_common.c:1156: error: 'struct irlan_cb' has no member named 'list'
net/irda/irlan/irlan_common.c:1156: warning: type defaults to 'int' in declaration of '__mptr'
net/irda/irlan/irlan_common.c:1156: error: 'struct irlan_cb' has no member named 'list'

I'll fix this, but I will not next time.  Instead, I'll revert all of
your changes and push it back to you.

Thanks.
