From: Adrian Bunk <bunk@stusta.de>
Subject: IBM_EMAC_PHY_RX_CLK_FIX depends on non-existing option 440GR
Date: Tue, 7 Feb 2006 23:14:49 +0100
Message-ID: <20060207221449.GB3524@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-embedded@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	Jean-Luc Leger <reiga@dspnet.fr.eu.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965037AbWBGWOw@vger.kernel.org>
To: ebs@ebshome.net
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean-Luc Leger <reiga@dspnet.fr.eu.org> reported the following:

from drivers/net/Kconfig:
config IBM_EMAC_PHY_RX_CLK_FIX
        bool "PHY Rx clock workaround"
        depends on IBM_EMAC && (405EP || 440GX || 440EP || 440GR)
-> maybe this is 440GP ?


The non-existing CONFIG_440GR is also present in the driver itself.

Is this a typo or a not yet merged platform?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
