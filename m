From: kaber@trash.net
Subject: [PATCH 0/6] ipv6: ip6mr: support multiple independant multicast routing instances
Date: Tue, 11 May 2010 16:02:25 +0200
Message-ID: <1273586551-3521-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40378 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757969Ab0EKOCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 10:02:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches add support for multiple independant IPv6 multicast
routing instances. This can be useful to seperate traffic when building
a multicast router that is serving multiple independant networks.

The patchset is pretty much a straight forward port from IPv4 with no
significant differences.

The patchset consists of the following parts:

- Patch 01-04 contain some preparatory work and cleanup for supporting
  multiple multicast routing instances.

- Patch 05 contains the actual changes to support multiple multicast
  routing instances.

- Patch 06 adds support for dumping multicast routing routes from all
  tables over netlink.

These patches have been tested using pim6sd and mrd6.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/ipmr-2.6.git master

Thanks!
