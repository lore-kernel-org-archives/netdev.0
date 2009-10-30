From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/6] Bonding simplifications and netns support
Date: Thu, 29 Oct 2009 17:16:54 -0700
Message-ID: <m1tyxhwxah.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:56213 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122AbZJ3AQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 20:16:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I recently had it pointed out to me that the bonding driver does not
work in a network namespace.  So I have simplified the bonding driver
a bit, added support for ip link add and ip link del, and finally made
the bonding driver work in multiple network namespaces.

The most note worthy change in the patchset is the addition of support
in the networking core for registering a sysfs group for a device.

Using this in the bonding driver simplifies the code and removes a
userspace race between actions triggered by the netlink event and the
bonding sysfs attributes appearing.

Eric


