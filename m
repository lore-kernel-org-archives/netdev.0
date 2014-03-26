From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 0/6] at86rf230: cleanups and add missing devicetree documentation
Date: Wed, 26 Mar 2014 15:11:51 +0100
Message-ID: <1395843117-16494-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this patch series contains some cleanups for at86rf230 driver.

The patch series contains:

 - Removing of the irq_type inside the platform data and use
   irq_get_trigger_type instead.
 - Use of devm_* functions.
 - At least we add a missed devicetree documentation. Sorry I didn't create
   one at intial devicetree support patch.

- Alex

Alexander Aring (6):
  at86rf230: use dev_* print functions
  at86rf230: use irq_get_trigger_type
  at86rf230: remove irq_type in request_irq
  at86rf230: use devm_request_irq
  at86rf230: use devm_gpio_request_one
  devicetree: add at86rf230 bindings

 .../bindings/net/ieee802154/at86rf230.txt          |  23 +++++
 drivers/net/ieee802154/at86rf230.c                 | 100 ++++++---------------
 include/linux/spi/at86rf230.h                      |  14 ---
 3 files changed, 51 insertions(+), 86 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/ieee802154/at86rf230.txt

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
