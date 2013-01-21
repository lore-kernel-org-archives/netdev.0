From: Peter =?iso-8859-1?q?H=FCwe?= <PeterHuewe@gmx.de>
Subject: Sparse Warnings: net/ipv6/route.c:521:17: sparse: context imbalance in 'rt6_probe' - different lock contexts for basic block
Date: Mon, 21 Jan 2013 21:03:17 +0100
Message-ID: <201301212103.18066.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: "YOSHIFUJI Hideaki / =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:65274 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756205Ab3AUUAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 15:00:13 -0500
Received: from mailout-de.gmx.net ([10.1.76.30]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0Lm9rr-1TNlnu3Ep7-00Zjxl for
 <netdev@vger.kernel.org>; Mon, 21 Jan 2013 21:00:11 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi YOSHIFUJI,

FYI, there are new sparse warnings show up in

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
branch: master
head:   887c95cc1da53f66a5890fdeab13414613010097
commit: 2152caea719657579daa3a1a57a5425a3db6d612 [185/189] ipv6: Do not depend 
on rt->n in rt6_probe().

>> net/ipv6/route.c:521:17: sparse: context imbalance in 'rt6_probe' - 
different lock contexts for basic block

On latest net-next/master it's
net/ipv6/route.c:500:17: warning: context imbalance in 'rt6_probe' - different 
lock contexts for basic block


Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Reported-by: Peter Huewe <peterhuewe@gmx.de>


Thanks,
Peter
