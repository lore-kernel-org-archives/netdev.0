From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request [net]: batman-adv 2014-01-16
Date: Thu, 16 Jan 2014 00:10:43 +0100
Message-ID: <1389827444-3911-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:12408 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678AbaAOXL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:11:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have a very small fix intended for net/linux-3.13.

This patch is fixing the batman-adv overhead computation
(by Marek Lindner).
The result of such operation is used to initialize the
hard_header_len member of the soft-interface netdev object.


Please pull or let me know of any problem!

Thanks a lot,
	Antonio



The following changes since commit 51bb352f15595f2dee42b599680809de3d08999d:

  qlge: Fix vlan netdev features. (2014-01-14 19:02:35 -0800)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 1df0cbd509bc21b0c331358c1f9d9a6fc94bada8:

  batman-adv: fix batman-adv header overhead calculation (2014-01-15 23:54:20 +0100)

----------------------------------------------------------------
Included change:
- properly compute the batman-adv header overhead. Such
  result is later used to initialize the hard_header_len
  member of the soft-interface netdev object

----------------------------------------------------------------
Marek Lindner (1):
      batman-adv: fix batman-adv header overhead calculation

 net/batman-adv/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
