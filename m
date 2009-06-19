From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: BUG: sleeping function called from invalid context at
	kernel/mutex.c:280
Date: Fri, 19 Jun 2009 07:17:16 +0000
Message-ID: <20090619071716.GA9090@ff.dom.local>
References: <a8e1da0906181936k66b8bb2cv63f0007f5fe067f3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756665AbZFSHRg@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a8e1da0906181936k66b8bb2cv63f0007f5fe067f3@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19-06-2009 04:36, Dave Young wrote:
> Hi,
> 
> with kernel 2.6.30-06692-g3fe0344, pppoe link, start firefox, then got
> the messages from syslog:

Hi,

probably you should say something about a char/serial driver used here.

Jarek P.
> 
> Jun 19 10:14:07 darkstar kernel: [  189.313972] BUG: sleeping function
> called from invalid context at kernel/mutex.c:280
> Jun 19 10:14:07 darkstar kernel: [  189.313976] in_atomic(): 1,
> irqs_disabled(): 0, pid: 2100, name: firefox-bin
> Jun 19 10:14:07 darkstar kernel: [  189.313980] 6 locks held by
> firefox-bin/2100:
> Jun 19 10:14:07 darkstar kernel: [  189.313981]  #0:
> (sk_lock-AF_INET){+.+.+.}, at: [<c12ed864>] lock_sock+0xa/0xc
> Jun 19 10:14:07 darkstar kernel: [  189.313991]  #1:
> (rcu_read_lock){.+.+..}, at: [<c12c002e>] dev_queue_xmit+0xd8/0x29c
> Jun 19 10:14:07 darkstar kernel: [  189.314000]  #2:
> (_xmit_PPP#2){+.-...}, at: [<c12cbee2>] __netif_tx_lock+0x11/0x18
> Jun 19 10:14:07 darkstar kernel: [  189.314008]  #3:
> (&ppp->wlock){+.-...}, at: [<c12224a8>] ppp_xmit_process+0x19/0x449
> Jun 19 10:14:07 darkstar kernel: [  189.314015]  #4:
> (&pch->downl){+.-...}, at: [<c1221cf2>] ppp_push+0x63/0x4d2
> Jun 19 10:14:07 darkstar kernel: [  189.314021]  #5:
> (&ap->xmit_lock){+.-...}, at: [<c1224ef0>] ppp_async_push+0x2f/0x3d0
> Jun 19 10:14:07 darkstar kernel: [  189.314029] Pid: 2100, comm:
> firefox-bin Not tainted 2.6.30-06692-g3fe0344-dirty #77
> Jun 19 10:14:07 darkstar kernel: [  189.314031] Call Trace:
> Jun 19 10:14:07 darkstar kernel: [  189.314036]  [<c102315e>]
> __might_sleep+0xe1/0xe6
> Jun 19 10:14:07 darkstar kernel: [  189.314041]  [<c1335dfd>]
> mutex_lock_nested+0x18/0x36
> Jun 19 10:14:07 darkstar kernel: [  189.314046]  [<c118d82f>]
> tty_throttle+0x10/0x38
> Jun 19 10:14:07 darkstar kernel: [  189.314050]  [<c118cc1c>]
> n_tty_receive_buf+0xf6e/0xf76
...
