From: Nguyen Hong Ky <nh-ky@jinso.co.jp>
Subject: [PATCH] net: sh_eth: Fix RX packets errors on R8A7740
Date: Mon,  7 Oct 2013 15:29:24 +0900
Message-ID: <1381127365-6521-1-git-send-email-nh-ky@jinso.co.jp>
Cc: netdev@vger.kernel.org,
	Ryusuke Sakato <ryusuke.sakato.bx@renesas.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m119.secure.ne.jp ([158.199.161.240]:27697 "HELO
	m119.secure.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752402Ab3JGGgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 02:36:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David S. Miller,

This patch will fix RX packets errors when receiving big size of data.
Moreover, I set suitable parameters for get more stable when receiving
packets.

It was created on the top of mainline kernel v3.11.

I tested this patch on Armadillo800eva, it appears to be working well.

Would you please review and apply it for me.

Thank you,
Nguyen Hong Ky

Nguyen Hong Ky (1):
  net: sh_eth: Fix RX packets errors on R8A7740

 drivers/net/ethernet/renesas/sh_eth.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

-- 
1.7.5.4
