From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net 0/4] xen-netback: Fixing up xenvif_tx_check_gop
Date: Thu, 17 Jul 2014 20:09:48 +0100
Message-ID: <1405624192-21722-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10094 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbaGQTKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 15:10:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
