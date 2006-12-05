From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: 2.6.19-git6 header error
Date: Mon, 4 Dec 2006 17:03:24 -0800
Message-ID: <20061204170324.41fedf13.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:42256 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758404AbWLEBCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 20:02:44 -0500
To: lkml <linux-kernel@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

linux-2.6.19-git6/usr/include/linux/netfilter.h requires linux/rcupdate.h, which does not exist in exported headers
make[3]: *** [/var/linsrc/linux-2.6.19-git6/usr/include/linux/.check.netfilter.h] Error 1
make[2]: *** [linux] Error 2
make[1]: *** [headers_check] Error 2
make: *** [vmlinux] Error 2

---
~Randy
