From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 00/10] Remove multiple uses of KERN_<level>
Date: Mon, 25 Oct 2010 19:44:18 -0700
Message-ID: <cover.1288059486.git.joe@perches.com>
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Chas Williams <chas-vT06rRrALxcmhCb6mdbn6A@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alessandro Rubini <rubini-JCs+bAQazDroPXhRcRtihA@public.gmane.org>,
	Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"James E.J. Bottomley" <James.Bottomley-l3A5Bk7waGM@public.gmane.org>,
	David Brown <davidb-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Daniel Walker <dwalker-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Bryan Huntsman <bryanh-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s
To: Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Found using strings vmlinux | grep "^<.>.*<.>"
and a couple of other cleanups of logging message format strings.

Joe Perches (10):
  arch/x86/kernel/apic/io_apic.c: Typo fix WARNING
  drivers/atm/eni.c: Remove multiple uses of KERN_<level>
  drivers/hid/hid-input.c: Remove KERN_DEBUG from dbg_hid use
  drivers/infiniband: Remove unnecessary KERN_<level> uses
  drivers/input/mouse/appletouch.c: Remove KERN_DEBUG use from dprintk
  drivers/input/serio/i8042: Use pr_<level>, pr_fmt.  Fix dbg and __FILE__ use
  drivers/media: Removed unnecessary KERN_<level>s from dprintk uses
  drivers/scsi:mvsas/mv_sas.c: Remove KERN_DEBUG from mv_dprintk use
  drivers/video/msm/mddi.c: Remove multiple KERN_<level> uses
  fs/proc/vmcore.c: Use pr_<level> and pr_<fmt>

 arch/x86/kernel/apic/io_apic.c                |    2 +-
 drivers/atm/eni.c                             |    7 +-
 drivers/hid/hid-input.c                       |    2 +-
 drivers/infiniband/hw/amso1100/c2_intr.c      |    4 +-
 drivers/infiniband/hw/cxgb3/iwch_cm.c         |    4 +-
 drivers/infiniband/hw/cxgb4/cm.c              |    4 +-
 drivers/input/mouse/appletouch.c              |    2 +-
 drivers/input/serio/i8042.c                   |   94 ++++++++++++-------------
 drivers/input/serio/i8042.h                   |   19 +++--
 drivers/media/common/tuners/max2165.c         |   10 +--
 drivers/media/dvb/frontends/atbm8830.c        |    8 +--
 drivers/media/dvb/frontends/lgs8gxx.c         |   11 +--
 drivers/media/video/saa7134/saa7134-input.c   |    2 +-
 drivers/media/video/saa7134/saa7134-tvaudio.c |   12 ++--
 drivers/scsi/mvsas/mv_sas.c                   |    2 +-
 drivers/video/msm/mddi.c                      |    5 +-
 fs/proc/vmcore.c                              |   16 ++---
 17 files changed, 97 insertions(+), 107 deletions(-)

-- 
1.7.3.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
