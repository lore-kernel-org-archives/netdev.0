From: Sven Eckelmann <sven@narfation.org>
Subject: Stable fixes for batman-adv
Date: Sat, 20 Dec 2014 13:48:54 +0100
Message-ID: <1419079737-31107-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:58305 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752895AbaLTM61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 07:58:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

it seems that patches aren't forwarded anymore (since August?) from batman-adv
to the netdev mailing list. Please correct me if I am wrong.

I would hereby try to send some patches directly to the netdev mailing list
instead of waiting any longer for the patches to be forwarded. There are more
non-feature patches [1] waiting in the batman-adv repo (everything after
"batman-adv: fix alignment" from 2014-05-15) but these don't seem to
be related to crashes.

At least the first patch caused crashes in real world scenarios [2] and could
also be used to crash a mesh node on-demand. The last patch has its bug report
in the linux bug tracker [3]. The second patch is a wrong size calculation but
no problem was yet observed in the wild.

All patches fix problems which were introduced in Linux 3.13.

Kind regards,
	Sven

[1] http://git.open-mesh.org/batman-adv.git/shortlog/refs/heads/maint
[2] https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2014-November/012561.html
[3] https://bugzilla.kernel.org/show_bug.cgi?id=84061
