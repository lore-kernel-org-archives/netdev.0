From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: spinlock BUG on b44 netconsole
Date: Fri, 30 Dec 2005 01:59:15 +0100
Message-ID: <20051230005915.GA16587@electric-eye.fr.zoreil.com>
References: <21d7e9970512281915q5f58e32bj456b29af52e2e8fe@mail.gmail.com> <21d7e9970512281915s29cf5ac5p33995791c716fc0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751188AbVL3BAV@vger.kernel.org>
To: Dave Airlie <airlied@gmail.com>
Content-Disposition: inline
In-Reply-To: <21d7e9970512281915s29cf5ac5p33995791c716fc0f@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(netdev Cced)

Dave Airlie <airlied@gmail.com> :
[...]

Replace the spinlock in b44_start_xmit by the irq_{save/restore} version.
Do the same around for spin_lock(&np->dev->xmit_lock); in netpoll_send_skb.

If it helps, it's an ugly, buggy, bandaid and you should consider
capturing the messages through a serial cable instead.

If you want to read the details, see the thread "Netconsole violates
dev->hard_start_xmit synch rules" started the 06/09/2005 on
netdev@vger.kernel.org.

--
Ueimor
