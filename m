From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH][ATM]: [clip] fix race between modifying entry->vccs and clip_start_xmit()
Date: Mon, 15 Sep 2003 22:59:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915225901.A22239@electric-eye.fr.zoreil.com>
References: <200309151911.h8FJBKSa003299@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
Content-Disposition: inline
In-Reply-To: <200309151911.h8FJBKSa003299@ginger.cmf.nrl.navy.mil>; from chas@cmf.nrl.navy.mil on Mon, Sep 15, 2003 at 03:11:21PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

chas williams <chas@cmf.nrl.navy.mil> :
[unlink_clip_vcc() locking change]

Afaik unlink_clip_vcc() can be called from a clip_push() issued in IRQ
context through vcc->push() in a device driver as well as from user-space
through vcc_ioctl()/ATMARP_SETENTRY. If the lock is taken by user-space
first, what avoids that unlink_clip_vcc(IRQ) deadlocks on it ?

No comment for the clip_start_xmit() part btw.

--
Ueimor
