From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 00/10] cxgb4vf: a number of bug fixes and minor cleanup
Date: Wed, 10 Nov 2010 18:01:33 -0800
Message-ID: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24639 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219Ab0KKCBf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 21:01:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch set includes a number of bug fixes and some minor c=
leanup for the cxgb4vf network driver.  If there are any problems with =
formatting, etc. of the patch set please just reject the patch set and =
kick my butt =97 I'm still a novice at putting these together!

 drivers/net/cxgb4vf/adapter.h      |    2 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c |   72 +++++++++++++-------
 drivers/net/cxgb4vf/sge.c          |  131 ++++++++++++++++++++++------=
--------
 drivers/net/cxgb4vf/t4vf_common.h  |   29 ++++----
 drivers/net/cxgb4vf/t4vf_hw.c      |   23 ++++++-
 5 files changed, 165 insertions(+), 92 deletions(-)

Casey