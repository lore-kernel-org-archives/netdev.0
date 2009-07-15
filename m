From: <jon_zhou@agilent.com>
Subject: why some packets lost during transmission?
Date: Wed, 15 Jul 2009 17:17:27 +0800
Message-ID: <60230E21F17E384C9BF0B9C98D9E3FDC04B4D3D8@sgp-sg-mb02.sgp.agilent.com>
References: <A353FA76-7D71-425F-BD67-FEE6DC26EF6F@cs.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aglsgpbs01.sgp.agilent.com ([192.25.82.30]:41788 "EHLO
	aglsgpbs01.sgp.agilent.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752185AbZGOJUW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2009 05:20:22 -0400
Received: from mppd (localhost.localdomain [127.0.0.1])
	by aglsgpbs01.sgp.agilent.com (Postfix) with ESMTP id 22AEE84186
	for <netdev@vger.kernel.org>; Wed, 15 Jul 2009 09:20:19 +0000 (GMT)
Received: from SGP-SG-BH03.sgp.agilent.com (sgp-sg-bh03.sgp.agilent.com [141.183.6.41])
	by aglsgpbs01.sgp.agilent.com (Postfix) with ESMTP id 1F4F284183
	for <netdev@vger.kernel.org>; Wed, 15 Jul 2009 09:20:19 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <A353FA76-7D71-425F-BD67-FEE6DC26EF6F@cs.uni-bonn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi

I try to send packets like this:

for (i=0;i<loop;i++)
{
    dev->hard_start_xmit(my_skb,dev);
}

the 'dev' point to network device.

but too many packets lost if the 'loop' is big(i.e. 5000),  I suspect the tx buffer of the NIC is full,but the driver does not print any related info.

how does the upper layer(i.e.arp,qdisc) handle this situation?



Thanks&Regards,
zhou rui

