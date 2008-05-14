From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] fec_mpc52xx: MPC52xx_MESSAGES_DEFAULT: 2nd NETIF_MSG_IFDOWN
 => IFUP
Date: Wed, 14 May 2008 10:10:43 +0200
Message-ID: <482A9E83.6060703@gmail.com>
References: <482A05E7.90204@gmail.com> <482A8DFD.3080805@246tnt.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Sylvain Munaut <tnt@246tnt.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:43066 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760997AbYENIKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 04:10:46 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1384018nfc.21
        for <netdev@vger.kernel.org>; Wed, 14 May 2008 01:10:44 -0700 (PDT)
In-Reply-To: <482A8DFD.3080805@246tnt.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sylvain Munaut wrote:
> Roel Kluin wrote:
>> in drivers/net/fec_mpc52xx.c:81 it reads:
>>
>> #define MPC52xx_MESSAGES_DEFAULT ( NETIF_MSG_DRV | NETIF_MSG_PROBE | \
>>                 NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFDOWN )
>>
>> should this maybe be 
>>
>> NETIF_MSG_IFUP | NETIF_MSG_IFDOWN )
>>
>> ?
>>
>>   
> Yes but I remember seeing a patch for this already ... What kernel
> version / revision do you have ?
> 
> Sylvain

Indeed I already sent the patch, see http://lkml.org/lkml/2008/1/30/252 (my
emailaddress changed), but there was no response and the patch isn't included in
current Linus' git. maybe if you could add your ack?
---
duplicate NETIF_MSG_IFDOWN, 2nd should be NETIF_MSG_IFUP

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 5f9c42e..329edd9 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -78,7 +78,7 @@ module_param_array_named(mac, mpc52xx_fec_mac_addr, byte, NULL, 0);
 MODULE_PARM_DESC(mac, "six hex digits, ie. 0x1,0x2,0xc0,0x01,0xba,0xbe");
 
 #define MPC52xx_MESSAGES_DEFAULT ( NETIF_MSG_DRV | NETIF_MSG_PROBE | \
-		NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFDOWN )
+		NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP)
 static int debug = -1;	/* the above default */
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "debugging messages level");
