From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: sctp: implement sctp_v6_destroy_sock()
Date: Thu, 03 Dec 2015 12:06:41 -0500 (EST)
Message-ID: <20151203.120641.1445164595074464179.davem@davemloft.net>
References: <565DAD8D.9020800@iogearbox.net>
	<1448980723.25582.24.camel@edumazet-glaptop2.roam.corp.google.com>
	<1448983207.25582.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, dvyukov@google.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com,
	edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448983207.25582.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Dec 2015 07:20:07 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry Vyukov reported a memory leak using IPV6 SCTP sockets.
> 
> We need to call inet6_destroy_sock() to properly release
> inet6 specific fields.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
