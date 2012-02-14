From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 0/7] mlx4: Bug fixes and cleanups
Date: Tue, 14 Feb 2012 18:37:09 +0200
Message-ID: <4F3A8DB5.3020703@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:43217 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751796Ab2BNQj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 11:39:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,
This is a series of fixes and cleanups for mlx4_core driver,
Most of them related tracking of VF resources.
The fixes solve issues caused when the VF don't close gracefully (FLR for example)

Thanks,
Yevgeny
---

 main.c             |    4 +---
 mcg.c              |   38 ++++++++++++++------------------------
 mlx4.h             |    1 -
 port.c             |    2 --
 resource_tracker.c |   21 +++++++++++++--------
 5 files changed, 28 insertions(+), 38 deletions(-)
