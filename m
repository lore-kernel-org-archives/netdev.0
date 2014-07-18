From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net 0/4 v2] xen-netback: Fixing up xenvif_tx_check_gop
Date: Fri, 18 Jul 2014 19:08:01 +0100
Message-ID: <1405706885-16763-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes a lot of bugs on the error path around this function, which
were introduced with my grant mapping series in 3.15. They apply to the latest
net tree, but probably to net-next as well without any modification.
I'll post an another series which applies to 3.15 stable, as the problem was
first discovered there. The only difference is that the "queue" variable name is
replaced to "vif".

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Reported-by: Armin Zentai <armin.zentai@ezit.hu>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
