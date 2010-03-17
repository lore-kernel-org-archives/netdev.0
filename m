From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] netpoll: allow spaces in its parameter
Date: Tue, 16 Mar 2010 22:59:50 -0700 (PDT)
Message-ID: <20100316.225950.222623826.davem@davemloft.net>
References: <20100317055707.5013.72217.sendpatchset@localhost.localdomain>
	<20100316.225431.200776775.davem@davemloft.net>
	<4BA07022.1040702@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BA07022.1040702@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Wed, 17 Mar 2010 14:01:06 +0800

> The problem is that the dst port is 0 when I even use:
> 
> "netconsole=@192.168.0.1/eth0, 66666@192.168.0.2/"
> 
> This is awful too? I don't think so...

It's very simple, don't use spaces.  Is it so difficult
to follow this rule?

"ipconfig" does it as do a host of other kernel command
line options.

There is no real reason to make netconsle= special in
this regard, really.
