From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request net: 2013-08-17b
Date: Sat, 17 Aug 2013 13:04:44 +0200
Message-ID: <1376737486-1863-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:25716 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722Ab3HQLb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 07:31:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here is the correct pull request for net/linux-3.11.

As described earlier this patchset contains a change which properly end=
s a
seq_read cycle and another change that takes care of aborting TX operat=
ions if
the skb preparation should faile.

Please pull or let me know if there is any problem.

(about merge of net into net-next?)

Thanks a lot!
	Antonio


The following changes since commit 0f7dd1aa8f959216f1faa71513b9d3c1a906=
5e5a:

  Merge tag 'clk-fixes-for-linus' of git://git.linaro.org/people/mturqu=
ette/linux (2013-08-16 10:00:18 -0700)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to d823c33c0717cffea2dc73180ef780bf626908c7=
:

  batman-adv: check return type of unicast packet preparations (2013-08=
-17 12:52:27 +0200)

----------------------------------------------------------------
Included change:
- Add a missing skb_abort_seq_read() to properly close seq_read session
- Check if the skb has been correctly prepared before going on

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: properly end seq_read session

Linus L=C3=BCssing (1):
      batman-adv: check return type of unicast packet preparations

 net/batman-adv/main.c    |  1 +
 net/batman-adv/unicast.c | 10 +++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)
