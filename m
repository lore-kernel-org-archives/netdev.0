From: Adrian Bunk <bunk@stusta.de>
Subject: firmware in drivers/net/bnx2_fw{,2}.h
Date: Mon, 9 Jul 2007 20:40:58 +0200
Message-ID: <20070709184058.GI3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:55857 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752739AbXGISk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 14:40:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

$ filterdiff -z -i \*bnx2_fw\* patch-2.6.22.gz | diffstat -p1 -w72
 drivers/net/bnx2_fw.h  | 1697 +++++---
 drivers/net/bnx2_fw2.h | 7868 ++++++++++++++++++++---------------------
 2 files changed, 4982 insertions(+), 4583 deletions(-)
$ 

Please switch this driver to use request_firmware().

TIA
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

