From: Andrew Morton <akpm@osdl.org>
Subject: e100 changes in git-netdev-all break reboot with netconsole
Date: Thu, 28 Sep 2006 01:15:16 -0700
Message-ID: <20060928011516.54a38d4f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61059 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751767AbWI1IQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 04:16:46 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Enable netconsole-over-e100, and `reboot -f' hangs.  Disabling netconsole
prevents that from happening.

I assume what's happening is that the driver gets shut down and then
something tries to do a printk through it, and things hang.

For some reason sysrq-B still reboots the machine.
