From: Phil Karn <karn@qualcomm.com>
Subject: Patch to drivers/usb/serial/sierra.c to support Sierra Wireless Aircard
 595U
Date: Tue, 12 Jun 2007 19:34:46 -0700
Message-ID: <466F57C6.7080909@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from warlock.qualcomm.com ([129.46.50.49]:53439 "EHLO
	warlock.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbXFMDD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 23:03:26 -0400
Received: from numenor.qualcomm.com (numenor.qualcomm.com [129.46.51.58])
	by warlock.qualcomm.com (8.13.6/8.13.6/1.0) with ESMTP id l5D2f73C011839
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 19:41:07 -0700 (PDT)
Received: from hamtaro.qualcomm.com (hamtaro.qualcomm.com [129.46.61.157])
	by numenor.qualcomm.com (8.13.6/8.12.5/1.0) with ESMTP id l5D2YllG018689
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 19:34:48 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

*** linux-2.6.21.5/drivers/usb/serial/sierra.c	Mon Jun 11 11:37:06 2007
--- linux-2.6.21.5a/drivers/usb/serial/sierra.c	Fri Jun  8 23:37:06 2007
***************
*** 44,49 ****
--- 44,50 ----

   	{ USB_DEVICE(0x1199, 0x0112) }, /* Sierra Wireless AirCard 580 */
   	{ USB_DEVICE(0x0F3D, 0x0112) }, /* AirPrime/Sierra PC 5220 */
+ 	{ USB_DEVICE(0x1199, 0x0120) }, /* Sierra Wireless Aircard 595U */
   	{ }
   };
   MODULE_DEVICE_TABLE(usb, id_table);
***************
*** 66,71 ****
--- 67,73 ----
   	{ USB_DEVICE(0x1199, 0x6803) },	/* Sierra Wireless MC8765 */
   	{ USB_DEVICE(0x1199, 0x6812) },	/* Sierra Wireless MC8775 */
   	{ USB_DEVICE(0x1199, 0x6820) },	/* Sierra Wireless AirCard 875 */
+ 	{ USB_DEVICE(0x1199, 0x0120) }, /* Sierra Wireless Aircard 595U */
   	{ }
   };

