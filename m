From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix oops from tcp_collapse() when using splice()
Date: Tue, 30 Mar 2010 13:56:22 -0700 (PDT)
Message-ID: <20100330.135622.233398574.davem@davemloft.net>
References: <1269981913-18073-1-git-send-email-steve@digidescorp.com>
	<20100330.134741.203608594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, monstr@monstr.eu, karl@hiramoto.org
To: steve@digidescorp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100330.134741.203608594.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 30 Mar 2010 13:47:41 -0700 (PDT)

> From: "Steven J. Magnani" <steve@digidescorp.com>
> Date: Tue, 30 Mar 2010 15:45:13 -0500
> 
>> tcp_read_sock() can have a eat skbs without immediately advancing copied_seq.
>> This can cause a panic in tcp_collapse() if it is called as a result
>> of the recv_actor dropping the socket lock.
>> 
>> A userspace program that splices data from a socket to either another
>> socket or to a file can trigger this bug.
>> 
>> Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
> 
> Thanks for fixing this I'll look at your patch more closely
> right now.

Patch applied, thanks Steven!
