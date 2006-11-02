From: "Patel, Shalin" <shalinip@ti.com>
Subject: Big Endian PCI driver
Date: Thu, 2 Nov 2006 10:37:20 +0530
Message-ID: <B2EAB41A1AF603458C6A01E3CC809C44027F009F@dbde01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from calf.ext.ti.com ([198.47.26.144]:43717 "EHLO calf.ext.ti.com")
	by vger.kernel.org with ESMTP id S1750970AbWKBFHo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 00:07:44 -0500
Received: from dlep34.itg.ti.com ([157.170.170.115])
	by calf.ext.ti.com (8.13.7/8.13.7) with ESMTP id kA257Ntf014011
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 1 Nov 2006 23:07:33 -0600
Received: from dlep95.itg.ti.com (localhost [127.0.0.1])
	by dlep34.itg.ti.com (8.13.7/8.13.7) with ESMTP id kA257NrB029568
	for <netdev@vger.kernel.org>; Wed, 1 Nov 2006 23:07:23 -0600 (CST)
Received: from dbde01.ent.ti.com (localhost [127.0.0.1])
	by dlep95.itg.ti.com (8.13.7/8.13.7) with ESMTP id kA257LkJ028687
	for <netdev@vger.kernel.org>; Wed, 1 Nov 2006 23:07:22 -0600 (CST)
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi, 

I am trying to run PCI based Ethernet card (RTL 8139) on a big endian
host. 

The pci controller that I have does not have any mechanism for swapping
the Big Endian data to Little Endian. While running the 8139too.c driver
I see that the data generated on the line is Endian swapped. 

In the data sheet of RTL 8139 I could not find any BSWAP bit neither the
8139too.c driver does any swapping of data while transmitting or
receiving. However, if I change the driver to swap data before
transmitting and after receiving I am able to get it working.

Does the RTL 8139 driver in 2.6.10 support Big Endian? Is there any
other Ethernet card driver which supports big endian host (with a PCI
controller which does not support byte swapping)?

Thanks,
Shalin Patel
