From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 00/11] treewide: rename dev_info variables to something else
Date: Mon,  5 Apr 2010 12:05:30 -0700
Message-ID: <cover.1270493677.git.joe@perches.com>
References: <20100304232928.2e45bdd1.akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Mark Gross <mark.gross-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Thompson <dougthompson-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Mike Isely <isely-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	David Vrabel <david.vrabel-kQvG35nSl+M@public.gmane.org>,
	linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bluesmoke-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100304232928.2e45bdd1.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is a macro called dev_info that prints struct device specific
information.  Having variables with the same name can be confusing and
prevents conversion of the macro to a function.

Rename the existing dev_info variables to something else in preparation
to converting the dev_info macro to a function.

Joe Perches (11):
  arch/ia64/hp/common/sba_iommu.c: Rename dev_info to adi
  drivers/usb/host/hwa-hc.c: Rename dev_info to hdi
  drivers/usb/wusbcore/wusbhc.h: Remove unused dev_info from struct wusb_port
  drivers/s390/block/dcssblk.c: Rename dev_info to ddi
  drivers/edac/amd: Rename dev_info to adi
  drivers/edac/cpc925_edac.c: Rename dev_info to cdi
  drivers/edac/e7*_edac.c: Rename dev_info to edi
  drivers/staging/iio: Rename dev_info to idi
  pvrusb2-v4l2: Rename dev_info to pdi
  drivers/char/mem.c: Rename dev_info to bdi
  drivers/uwb: Rename dev_info to wdi

 arch/ia64/hp/common/sba_iommu.c            |    8 +-
 drivers/char/mem.c                         |    6 +-
 drivers/edac/amd8111_edac.c                |   88 ++++----
 drivers/edac/amd8131_edac.c                |   86 ++++----
 drivers/edac/cpc925_edac.c                 |  122 +++++-----
 drivers/edac/e752x_edac.c                  |   18 +-
 drivers/edac/e7xxx_edac.c                  |    8 +-
 drivers/media/video/pvrusb2/pvrusb2-v4l2.c |   22 +-
 drivers/s390/block/dcssblk.c               |  328 ++++++++++++++--------------
 drivers/staging/iio/accel/lis3l02dq_core.c |    4 +-
 drivers/staging/iio/accel/lis3l02dq_ring.c |   20 +-
 drivers/staging/iio/accel/sca3000_core.c   |   24 +-
 drivers/staging/iio/adc/max1363_core.c     |   36 ++--
 drivers/staging/iio/adc/max1363_ring.c     |    6 +-
 drivers/staging/iio/chrdev.h               |    2 +-
 drivers/staging/iio/iio.h                  |   54 +++---
 drivers/staging/iio/industrialio-core.c    |  232 ++++++++++----------
 drivers/staging/iio/industrialio-ring.c    |   38 ++--
 drivers/staging/iio/industrialio-trigger.c |   34 ++--
 drivers/staging/iio/ring_generic.h         |    4 +-
 drivers/staging/iio/trigger_consumer.h     |   16 +-
 drivers/usb/host/hwa-hc.c                  |   18 +-
 drivers/usb/wusbcore/wusbhc.h              |   10 -
 drivers/uwb/i1480/i1480u-wlp/lc.c          |   16 +-
 drivers/uwb/wlp/messages.c                 |   40 ++--
 drivers/uwb/wlp/sysfs.c                    |   46 ++--
 drivers/uwb/wlp/wlp-lc.c                   |   12 +-
 27 files changed, 644 insertions(+), 654 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
