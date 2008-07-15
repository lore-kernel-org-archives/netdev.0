From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v4 [PATCH 0/9] Check return of dev_set_promiscuity/allmulti
Date: Tue, 15 Jul 2008 10:59:01 +0800
Message-ID: <487C1275.3040103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57255 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754597AbYGODEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 23:04:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3->v4:
- ipmr: unwind tunnel creating
- ipmr: fix unregister device oops
- ip6mr: fix using after dev_put()

This series of patch fix the places where calling
dev_set_promiscuity/allmulti but not do error handling
according to the return of dev_set_promiscuity/allmulti.

And among the patches, there is a patch fixes unregister
device oops of impr and a patch fixes using after dev_put().



