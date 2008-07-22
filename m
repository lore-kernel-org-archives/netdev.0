From: Adrian Bunk <bunk@kernel.org>
Subject: struct tpacket_auxdata userspace ABI breakage
Date: Tue, 22 Jul 2008 19:08:44 +0300
Message-ID: <20080722160844.GK14846@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:35903 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277AbYGVQIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 12:08:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 393e52e33c6c26ec7db290dab803bac1bed962d4
(packet: deliver VLAN TCI to userspace) adds a
member tp_vlan_tci to struct tpacket_auxdata.

This changes the size of the struct, and unless I miss something
it is an ABI change that must be reverted.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

