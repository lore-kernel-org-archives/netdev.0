From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [RFC] [PATCH 0/8] net-next: Phonet fixes and cleanup
Date: Mon, 7 Mar 2011 12:45:47 +0200
Message-ID: <201103071245.47722.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.26]:31186 "EHLO mgw-da02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab1CGKoy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 05:44:54 -0500
Received: from leon.remlab.net (esdhcp034153.research.nokia.com [172.21.34.153])
	by mgw-da02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p27Aip8Q005054
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2011 12:44:52 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As "promised", here is the cleaned up and unified Phonet pipe code.
The same kernel can now support both old (e.g. Nokia N900) and new
(e.g. ST-Ericsson U8500 SoC) modems.

Changes are available in the git repository at:

  git://git.remlab.net/linux-phonet.git master

R=C3=A9mi Denis-Courmont (8):
      Phonet: fix NULL-deref in previous patch series
      Phonet: return an error when TX fails
      Phonet: fix backlog callback return value
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
