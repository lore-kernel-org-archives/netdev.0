From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 6/10] include/linux/usb/cdc.h:47:5: warning:
 'struct usb_interface' declared inside parameter list
Date: Tue, 15 Sep 2015 13:25:38 -0700 (PDT)
Message-ID: <20150915.132538.2065465403874989751.davem@davemloft.net>
References: <201509160313.6mZCFUqL%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.com, kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbbIOUZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 16:25:41 -0400
In-Reply-To: <201509160313.6mZCFUqL%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Wed, 16 Sep 2015 03:56:14 +0800

> All warnings (new ones prefixed by >>):
> 
>    In file included from drivers/usb/gadget/function/u_serial.h:16:0,
>                     from drivers/usb/gadget/function/f_acm.c:23:
>>> include/linux/usb/cdc.h:47:5: warning: 'struct usb_interface' declared inside parameter list
>         int buflen);
>         ^
>>> include/linux/usb/cdc.h:47:5: warning: its scope is only this definition or declaration, which is probably not what you want

I'll fix this as follows:

====================
[PATCH] cdc: Fix build warning.

   In file included from drivers/usb/gadget/function/u_serial.h:16:0,
                    from drivers/usb/gadget/function/f_acm.c:23:
>> include/linux/usb/cdc.h:47:5: warning: 'struct usb_interface' declared inside parameter list
        int buflen);
        ^
>> include/linux/usb/cdc.h:47:5: warning: its scope is only this definition or declaration, which is probably not what you want

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/usb/cdc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/usb/cdc.h b/include/linux/usb/cdc.h
index cd8f2e1..959d0c8 100644
--- a/include/linux/usb/cdc.h
+++ b/include/linux/usb/cdc.h
@@ -40,7 +40,7 @@ struct usb_cdc_parsed_header {
 	bool phonet_magic_present;
 };
 
-
+struct usb_interface;
 int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
 				struct usb_interface *intf,
 				u8 *buffer,
-- 
2.1.0
