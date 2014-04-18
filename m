From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Subject: [PATCH 0/3] 6lowpan: few changes to help with backports
Date: Thu, 17 Apr 2014 18:22:53 -0700
Message-ID: <1397784176-15809-1-git-send-email-mcgrof@do-not-panic.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Here's a few changes that can help automate the backport of 6lowpan.
I've been carrying them around for a while, I think its best to just
merge these upstream as its nothing controversial.

Luis R. Rodriguez (3):
  6lowpan: add helper to get 6lowpan namespace
  6lowpan: make lowpan_cb static
  6lowpan: include net/net_namespace.h on 6lowpan namepsace header

 include/net/6lowpan.h       |  1 +
 include/net/net_namespace.h | 15 ++++++++++++++
 net/ieee802154/reassembly.c | 48 +++++++++++++++++++++++++++++----------------
 3 files changed, 47 insertions(+), 17 deletions(-)

-- 
1.9.1
