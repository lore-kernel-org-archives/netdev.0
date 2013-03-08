From: Loic Domaigne <loic.domaigne-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: RFC: [PATCH 0/3] usb: cdc_ncm: patches for MirrorLink
Date: Fri, 8 Mar 2013 22:03:16 +0100
Message-ID: <20130308210316.GA4793@feynman.loic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following serie of patches has been devised at jambit within the 
MirrorLink(TM) context. 

It contains:
- a patch for getting acceptable performance of the NCM driver under WMware 
  environment (tested so far up to Workstation 9.0) 
- a patch to have a single driver source for many kernel versions. This becomes
  handy if you need to support a wide range of kernel versions, as we do.
- a patch to boost transfer performance for the Nokia N60x, N70x.

patch3 depends on patch2, and patch 2 on patch1. The patches apply 
to longterm kernel version 3.4.35. 

We are aware that those patches may not be suited for the mainstream driver. 
On the other hand, jambit likes to make those patches public for anyone 
interested in those topics.

Thanks,
Loic
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
