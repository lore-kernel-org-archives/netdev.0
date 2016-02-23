From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: [PATCH 0/1] net and net-next merge conflict bug
Date: Tue, 23 Feb 2016 20:16:57 +0100
Message-ID: <1456255018-9632-1-git-send-email-clemens.gruber@pqgruber.com>
Cc: netdev@vger.kernel.org,
	Clemens Gruber <clemens.gruber@pqgruber.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pqgruber.com ([178.189.19.235]:21926 "EHLO
	mail.pqgruber.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131AbcBWTRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:17:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

in your merge commit b633353115e3 ("Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net"), you merged
net into net-next and commit 930b37ee8d84 ("net: phy: Add SGMII support
for Marvell 88E1510/1512/1514/1518") overwrote a fix from
commit 79be1a1c9090 ("phy: marvell: Fix and unify reg-init behavior").
Now, for the 88E1510, marvell_of_reg_init is not called anymore.

Solution:
Instead of returning 0 at m88e1510_config_init it should call
marvell_config_init.

I am sending you a patch for net-next to avoid any issues in case the
SGMII commit is merged back into davem/net. (?)

davem/net is fine, the problem exists only in davem/net-next.

Thanks,
Clemens

Clemens Gruber (1):
  phy: marvell: Fix 88E1510 initialization

 drivers/net/phy/marvell.c | 70 +++++++++++++++++++++++------------------------
 1 file changed, 35 insertions(+), 35 deletions(-)

-- 
2.7.1
