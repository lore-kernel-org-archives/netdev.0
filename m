From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: ip_auto_config bug in 2.6.20-rc6
Date: Thu, 01 Feb 2007 12:26:27 +0100
Message-ID: <1170329187.15627.11.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 147.175.241.83.in-addr.dgcsystems.net ([83.241.175.147]:19002
	"EHLO tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751714AbXBAL0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 06:26:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following commandline:
 root=/dev/mtdblock6 rw rootfstype=jffs2 ip=192.168.1.10:::255.255.255.0:localhost.localdomain:eth1:off console=ttyS0,115200
makes ip_auto_config fall back to DHCP and complain "IP-Config: Incomplete network configuration information."
depending on if CONFIG_IP_PNP_DHCP is set or not.

The only way I can make ip_auto_config accept my IP config is to add an entry for the server IP:
ip=192.168.1.10:192.168.1.15::255.255.255.0:localhost.localdomain:eth1:off

I think this is a bug since I am not using a NFS root FS.

 Jocke
