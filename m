From: frank.blaschka@de.ibm.com
Subject: [patch 0/4] s390: network patches for net-next
Date: Wed, 08 Sep 2010 09:14:38 +0200
Message-ID: <20100908071438.085729717@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:50100 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757723Ab0IHHQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:16:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 network patches for net-next.
We finally made it and converted the qeth layer 2 and layer 3
driver to NAPI (thanks to Jan Glauber who did the QDIO part).

shortlog:
Jan Glauber (1)
qdio: extend API to allow polling

Joe Perches (1)
qeth: Use %pI6

Mike Frysinger (1)
Kconfig: have CCWGROUP depend on CLAW

Frank Blaschka (1)
qeth: NAPI support for l2 and l3 discipline

Thanks,
        Frank
