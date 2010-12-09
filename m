From: "Govindarajan, Sriramakrishnan" <srk@ti.com>
Subject: Adding Support for SG,GSO,GRO
Date: Thu, 9 Dec 2010 16:03:29 +0530
Message-ID: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:59857 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756109Ab0LIKiR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 05:38:17 -0500
Received: from dbdp20.itg.ti.com ([172.24.170.38])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id oB9AcDsC025876
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 9 Dec 2010 04:38:16 -0600
Received: from dbde70.ent.ti.com (localhost [127.0.0.1])
	by dbdp20.itg.ti.com (8.13.8/8.13.8) with ESMTP id oB9AcDQi024068
	for <netdev@vger.kernel.org>; Thu, 9 Dec 2010 16:08:13 +0530 (IST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
We have a NAPI compliant driver(net/drivers/davinci_emac.c), that does well at 10/100Mbps loads. Now the same controller/driver is used for 1000Mbps
mode as well, where the CPU gets saturated easily

Internally the module supports scatter gather DMA(which is currently not
exercised) but there is no HW checksum support.

To specifically implement GRO, GSO support would it be sufficient to add
SG support to the driver? Are there other means of increasing the throughput
and decreasing the CPU loading?

Any pointers to reference implementation for adding SG/GRO/GSO support will be helpful.

Regards
Sriram
