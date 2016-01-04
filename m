From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH iproute2 0/4] addrgenmode updates for net-next
Date: Mon,  4 Jan 2016 10:58:02 +0100
Message-ID: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60599 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753042AbcADJ6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 04:58:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for the new "random" addrgenmode in net-next
and improves the support for the "stable_secret" mode.

Bj=C3=B8rn Mork (4):
  include: update kernel headers
  iplink: support setting addrgenmode stable_secret
  iplink: support show and set of "addrgenmode random"
  man: iplink: document new addrgenmodes

 include/linux/if_link.h |  1 +
 ip/ipaddress.c          |  3 +++
 ip/iplink.c             |  6 +++++-
 man/man8/ip-link.8.in   | 18 +++++++++++++++---
 4 files changed, 24 insertions(+), 4 deletions(-)

--=20
2.1.4
