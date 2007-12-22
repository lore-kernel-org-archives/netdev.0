From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [WEXT 0/12]: Un-crapify compat handling.
Date: Fri, 21 Dec 2007 20:52:40 -0800 (PST)
Message-ID: <20071221.205240.186733706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This set of 12 patches pulls all of the existing compat
handling for WEXT ioctls out of fs/compat_ioctl.c and
allows implementations down in the driver layers to
handle compat issues properly when necessary.

In particular it fixes the bug where iw_point objects
were not being size translated properly in scan
streams and similar.

Currently I've only made sure this compiles properly.
I'm half-way done with a dummy wireless driver that
can be used purely to validate WEXT ioctl handling
correctness in the core wireless layers.
