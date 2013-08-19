From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request net: 2013-08-19
Date: Mon, 19 Aug 2013 18:59:54 +0200
Message-ID: <1376931595-2070-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:50491 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab3HSRCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 13:02:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

after a not so quiet weekend, here is my small pull request intended fo=
r
net/linux-3.11.

This is a fix that aims to block TX operations in case of skb preparati=
on
failure.


Please pull or let me know of any problem.

Thanks,
	Antonio

p.s. is net going to be merged into net-next one of these days? I need =
it in
order to send a couple of changes to net-next.


The following changes since commit 0f7dd1aa8f959216f1faa71513b9d3c1a906=
5e5a:

  Merge tag 'clk-fixes-for-linus' of git://git.linaro.org/people/mturqu=
ette/linux (2013-08-16 10:00:18 -0700)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 50fa3b31f4700deb1a860fa1a04016b889765323=
:

  batman-adv: check return type of unicast packet preparations (2013-08=
-17 20:02:32 +0200)

----------------------------------------------------------------
Included change:
- Check if the skb has been correctly prepared before going on

----------------------------------------------------------------
Linus L=C3=BCssing (1):
      batman-adv: check return type of unicast packet preparations

 net/batman-adv/unicast.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)
