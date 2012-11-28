From: Anders Kaseorg <andersk-DPNOqEs/LNQ@public.gmane.org>
Subject: Wireless regression in workqueue: use mod_delayed_work() instead of
 __cancel + queue
Date: Wed, 28 Nov 2012 10:13:55 -0500 (EST)
Message-ID: <alpine.DEB.2.00.1211280953350.26602@dr-wily.mit.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-OBmyj6YDURU@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Herbert Xu <herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

My Intel 6250 wireless card (iwldvm) can no longer associate with a 
WPA-Enterprise network (PEAP-MSCHAPv2).  To my surprise, I bisected this 
regression to commit e7c2f967445dd2041f0f8e3179cca22bb8bb7f79, 
workqueue: use mod_delayed_work() instead of __cancel + queue.

A bunch of logs collected by Ubuntu apport are in this bug report: 
  https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1083980

How can I help to debug this?

I see that someone else reported another regression with the same commit 
last week, although this looks unrelated at first glance: 
  http://thread.gmane.org/gmane.linux.kernel/1395938

Anders
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
