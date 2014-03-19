From: Romeo Cane <romeo.cane.ext@coriant.com>
Subject: ethernet/freescale/gianfar.c broken on 3.10.x for TSEC
Date: Wed, 19 Mar 2014 13:32:59 +0000
Message-ID: <20140319133215.GA19172@rcane-VirtualBox>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1lp0013.outbound.protection.outlook.com ([213.199.154.13]:42239
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932721AbaCSNsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 09:48:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

the 3.10.x stable tree contains a bug in the Gianfar code that prevents the driver to work on old TSEC devices.
A patch for this issue has already been posted here and went upstream in 3.11 with commit 5eaedf31319d5f80eaaee1eec8dd18c0b452f0d1.
Since 3.10 has been selected for long term support and still contains the bug, I think it's worth considering to hand off this patch to Greg for backporting.

Thanks,
Romeo
