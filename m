From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [RFD] Network configuration data in sysfs
Date: Mon, 24 Oct 2011 02:35:58 +0300
Message-ID: <20111023233558.GA23264@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Alexey Gladkov <gladkov.alexey@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:52033 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902Ab1JWXf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Oct 2011 19:35:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Currently there's no way to set or inspect network configuration (protocol
addresses, routes, etc.) through sysfs. Yes, we have netlink interface for
this, but sysfs has advantage:

- change or inspect network configuration using standard unix utilities
  (echo, cat, etc.). It's useful at least in restricted environment where
  no special utilities available -- initrd or stripped down busybox.

- transparent udev support. It would be nice to get this information to
  udev.

Is there something fundamental preventing us to have sysfs interface for
network configuration?

-- 
 Kirill A. Shutemov
