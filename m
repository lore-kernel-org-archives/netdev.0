From: kuznet@ms2.inr.ac.ru
Subject: Re: qdisc_restart locking bug?
Date: Sat, 16 Nov 2002 00:41:25 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211152141.AAA26706@sex.inr.ac.ru>
References: <3DD54482.802@pobox.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com (Jeff Garzik)
In-Reply-To: <3DD54482.802@pobox.com> from "Jeff Garzik" at Nov 15, 2 02:01:22 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> When dev->hard_start_xmit() is called from qdisc_restart(), 
> dev->queue_lock is dropped, 

Using spin_unlock(). softirqs are not enabled.

>			and then re-acquired using only spin_lock().

Yes.


> So, doesn't qdisc_restart need s/spin_lock/spin_lock_bh/ for 
> dev->queue_lock?

It need not.

Alexey
