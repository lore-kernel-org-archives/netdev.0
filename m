From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for January 8 (net/ip.h, BUG=n)
Date: Fri, 8 Jan 2010 09:25:05 -0800
Message-ID: <20100108092505.4f4e1ac3.randy.dunlap@oracle.com>
References: <20100108164232.d3e1a164.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:62551 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab0AHRZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 12:25:39 -0500
In-Reply-To: <20100108164232.d3e1a164.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jan 2010 16:42:32 +1100 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20100107:


When CONFIG_BUG=n, CONFIG_GENERIC_BUG=n:

include/net/ip.h:341: error: implicit declaration of function '__WARN'

This affects:
make[3]: *** [security/selinux/hooks.o] Error 1
make[3]: *** [fs/ceph/messenger.o] Error 1
make[3]: *** [net/core/sock.o] Error 1
make[4]: *** [drivers/net/benet/be_main.o] Error 1


(this was on i386 builds)

---
~Randy
