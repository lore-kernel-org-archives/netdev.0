From: Alan Cox <alan@linux.intel.com>
Subject: Linux -next build failure
Date: Fri, 17 Aug 2012 16:03:42 +0100
Message-ID: <20120817160342.74d15dd5@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:47140 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932152Ab2HQOqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 10:46:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Build with CONFIG_TIGON3=y and CONFIG_HWMON=m

drivers/built-in.o: In function `tg3_close':
tg3.c:(.text+0xe223a): undefined reference to `hwmon_device_unregister'
drivers/built-in.o: In function `tg3_hwmon_open':
tg3.c:(.text+0xe6109): undefined reference to `hwmon_device_register'
