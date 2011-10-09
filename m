From: Alexander Guller <alexg@mellanox.com>
Subject: [PATCH 0/7] mlx4_en: bug fixes and performance enhancement
Date: Sun, 9 Oct 2011 17:26:19 +0200
Message-ID: <4E91BD1B.2040902@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexg@mellanox.com>,
	<yevgenyp@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49027 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751240Ab1JIP00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 11:26:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This is a series of patches for the mlx4_en driver generated against net-next tree.
The patches include several bug fixes and a fix for a better initialization of TX interrupts.

 en_cq.c      |   31 +++++++++-------
 en_ethtool.c |   14 ++++++-
 en_main.c    |    6 ++-
 en_netdev.c  |  112 ++++++++++++++++++++---------------------------------------
 en_port.c    |   18 +++++++--
 en_port.h    |   11 ++++-
 mlx4_en.h    |   15 +++----
 7 files changed, 103 insertions(+), 104 deletions(-)


Best regards,
Alex.
