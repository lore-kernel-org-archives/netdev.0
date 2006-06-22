From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: New Qlogic qla3xxx NIC Driver v2.02.00k31 for upstream inclusion
Date: Thu, 22 Jun 2006 14:00:15 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC07176862@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, "Linux Driver" <Linux-Driver@qlogic.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:19126 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S1750897AbWFVVAQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 17:00:16 -0400
Content-class: urn:content-classes:message
To: "Andrew Morton" <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew,

Thanks for your feedback.  I've fixed everything you mentioned with the
exception of the code below.  I need to swap every other byte pair of my
nvram mac address for big endian systems.  Everything else I tried was
more messy.  Did you have anything specific in mind?

Ron Mercer   


> 
> - Is there a better way of doing this?
> 
> static void ql_swap_mac_addr(u8 * macAddress) { #ifdef __BIG_ENDIAN
> 	u8 temp;
> 	temp = macAddress[0];
> 	macAddress[0] = macAddress[1];
> 	macAddress[1] = temp;
> 	temp = macAddress[2];
> 	macAddress[2] = macAddress[3];
> 	macAddress[3] = temp;
> 	temp = macAddress[4];
> 	macAddress[4] = macAddress[5];
> 	macAddress[5] = temp;
> #endif
> }
> 
