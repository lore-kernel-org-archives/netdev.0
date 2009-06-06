From: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/7] initdev:kernel:Introduction to initdev patchset
Date: Fri, 5 Jun 2009 19:34:00 -0700
Message-ID: <20090606023400.GA5562@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In days of yore, great fields of USB devices were discovered and initialized
long before they were harvested for use. Race conditions were unknown, and
all was well. As time passed in the land of Linux, the tilling of the bit
fields yielded great reductions in boot time, and there was much rejoicing.
Yet, some dispaired, for things were not as they had once been. The now-
hasty arrival at /bin/init startup meant some USB devices were not yet fully
ripened, leaving /dev/console unopened and network devices unconfigured.

This patch allows boot-time users of devices specified in kernel command line
parameters to wait until discovery and initialization of those devices.
The kernel command line that specify devices are "ip", "root", and "console".
This code supports device discovery on USB and SCSI buses. It mostly
eliminates the need for the rootwait kernel parameter.

This introduction is followed by 7 patches:
1	Basic initdev infrastructure
2	USB device discovery notification
3	Wait for console
4	Wait for network devices
5	USB and SCSI block device notification
6	Additional SCSI block device notification for asynchronous function
7	Wait for block device used for root

(Many thanks to Alan Stern, who said we could solve this without offensive
timeouts and then set about doing the integration into USB and SCSI)

Signed-off-by: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
---

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
