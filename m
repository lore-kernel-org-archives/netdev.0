From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 0/3] mlx4_en: Adding BQL support
Date: Mon, 23 Apr 2012 15:18:27 +0300
Message-ID: <4F954893.3040401@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:47421 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754768Ab2DWMSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 08:18:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

This patchset adds Byte Queue Limit support to the mlx4_en driver.
As a precondition to this I had to change the mode of TX completion handling
Till now we have handled completions by polling from the xmit context,
once in every 16 packets.
Now moving to interrupts, and also added the set/get coalescing option for TX interrupts.

Thanks,
Yevgeny

---
 en_cq.c      |   14 ++---------
 en_ethtool.c |   19 +++++++++++++--
 en_netdev.c  |   14 +++++++++--
 en_tx.c      |   74 +++++++++--------------------------------------------------
 mlx4_en.h    |    8 ++----
 5 files changed, 47 insertions(+), 82 deletions(-) 
