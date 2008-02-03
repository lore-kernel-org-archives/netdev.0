From: Li Zefan <lizf@cn.fujitsu.com>
Subject: latest git compile error in net/sched/cls_flow.c
Date: Sun, 03 Feb 2008 09:44:25 +0800
Message-ID: <47A51C79.7080804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59242 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932217AbYBCBp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 20:45:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I made a randconfig, and got the following error:

net/sched/cls_flow.c: In function 'flow_dump':
net/sched/cls_flow.c:598: error: 'struct tcf_ematch_tree' has no member named 'hdr'
make[2]: *** [net/sched/cls_flow.o] Error 1
make[1]: *** [net/sched] Error 2
make: *** [net] Error 2

seems it's caused by the following config options:
CONFIG_NET_EMATCH=n
CONFIG_NET_CLS_FLOW=y

