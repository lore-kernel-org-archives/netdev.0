From: David Miller <davem@davemloft.net>
Subject: Re: ssh server etc doesn't work anymore with net-2.6
Date: Sun, 11 Apr 2010 02:21:18 -0700 (PDT)
Message-ID: <20100411.022118.35346455.davem@davemloft.net>
References: <r2v86802c441004110217u15591f95ydd1e8e1466a36dc2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org
To: yinghai@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <r2v86802c441004110217u15591f95ydd1e8e1466a36dc2@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>
Date: Sun, 11 Apr 2010 02:17:09 -0700

> caused by:
> 
> commit 2626419ad5be1a054d350786b684b41d23de1538
> Author: David S. Miller <davem@davemloft.net>
> Date:   Thu Apr 8 11:32:30 2010 -0700
> 
>     tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb
> 
> it will make sshd server, telnet server and vnc server doesn't respond
> connecting request anymore.

I'll either fix or revert this, thanks for reporting.
