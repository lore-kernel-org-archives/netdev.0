From: Jean Delvare <jdelvare@suse.de>
Subject: Manual loading of mlx4_en
Date: Tue, 29 Jul 2014 11:53:32 +0200
Message-ID: <1406627612.4498.16.camel@chaos.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41061 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183AbaG2Jxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 05:53:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have a usability concern with the mlx4_en ethernet network driver. The
module aliases for all the supported devices are on the mlx4_core
module, so mlx4_core gets loaded automatically, but mlx4_en does not. I
must load mlx4_en manually (kernel 3.12.)

May I ask why the mlx4 driver was split into mlx4_core and mlx4_en in
the first place?

I have worked around the problem with the following modprobe directive:

install mlx4_core /sbin/modprobe --ignore-install mlx4_core && /sbin/modprobe mlx4_en

But this is kind of a hack and I would expect the right driver to load
automatically without magic.

Shouldn't the module aliases be attached to mlx4_en instead of
mlx4_core?

Thanks,
-- 
Jean Delvare
SUSE L3 Support
