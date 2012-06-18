From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] Introduce to batch variants of accept() and epoll_ctl() syscall
Date: Mon, 18 Jun 2012 16:27:47 -0700
Message-ID: <m2fw9s8aks.fsf@firstfloor.org>
References: <4FDAB652.6070201@gmail.com>
	<CABa6K_H3NrvvZ3Bh7JqsR6h33BSqYPBenUDG5Yt1U=2VvP700g@mail.gmail.com>
	<4FDACA26.70004@gmail.com> <1339750318.7491.70.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Li Yu <raise.sail@gmail.com>, Changli Gao <xiaosuo@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davidel@xmailserver.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339750318.7491.70.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Fri, 15 Jun 2012 10:51:58 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:
>
> I believe accept() is the problem here, because it contends with the
> softirq processing the tcp session handshake.

The MOSBENCH people some time ago did a per CPU accept queue. This is
probably overkill, but there are clearly some scaling problems here
with enough cores.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
