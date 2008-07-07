From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v3 [PATCH net-next 0/7] Check return of dev_set_promiscuity/allmulti
Date: Mon, 07 Jul 2008 10:31:48 +0800
Message-ID: <48718014.4030009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56190 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbYGGCge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 22:36:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is v3 of this series of patch.
This series of patch fix the places where calling dev_set_promiscuity/allmulti
but not do error handling according to the return of
dev_set_promiscuity/allmulti.

BTW, thanks Patrick who fixed a silly mistake of my patch
"netdevice: Fix promiscuity and allmulti overflow".

v2->v3
According to Patrick's review, do error handling when dev_set_promiscuity/allmulti
return negative.

