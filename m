From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [RFCv3] [PATCH 0/8] net-next: Phonet fixes and cleanup
Date: Tue, 8 Mar 2011 15:56:18 +0200
Message-ID: <201103081556.18877.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:36529 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754603Ab1CHN4W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 08:56:22 -0500
Received: from leon.remlab.net (esdhcp034153.research.nokia.com [172.21.34.153])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p28DuKkv004884
	for <netdev@vger.kernel.org>; Tue, 8 Mar 2011 15:56:20 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes are available in the git repository at:

  git://git.remlab.net/linux-phonet.git master

R=C3=A9mi Denis-Courmont (8):
      Phonet: fix NULL-deref in a8059512b120362b15424f152b2548fe8b11bd0=
c
      Phonet: return an error when skb TX fails
      Phonet: correct pipe backlog callback return values
      Phonet: factor common code to send control messages
      Phonet: allocate sock from accept syscall rather than soft IRQ
      Phonet: provide pipe socket option to retrieve the pipe identifie=
r
      Phonet: support active connection without pipe controller on mode=
m
      Phonet: kill the ST-Ericsson pipe controller Kconfig

 Documentation/networking/phonet.txt |   67 ++---
 include/linux/phonet.h              |    4 +-
 include/net/phonet/pep.h            |    1 -
 net/phonet/Kconfig                  |   12 -
 net/phonet/af_phonet.c              |   13 +-
 net/phonet/pep.c                    |  682 ++++++++++++++-------------=
--------
 net/phonet/socket.c                 |  112 +++----
 7 files changed, 352 insertions(+), 539 deletions(-)

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
