From: kaber@trash.net
Subject: [PATCH 00/19] netfilter: IPv6 NAT
Date: Thu,  9 Aug 2012 22:08:44 +0200
Message-ID: <1344542943-11588-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65310 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160Ab2HIUSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 16:18:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches contain an updated version of IPv6 NAT against
Linus' current tree.

The series is organized as follows:

- Patches 01-03 contain bugfixes for SIP helper bugs/regressions
  present in the current kernel

- Patches 04-06 improve conntrack fragmentation handling, the IPv6
  parts are also a precondition for IPv6 NAT

- Patches 07 and 08 prepare the current NAT code for conversion to
  an address family independant core, but contain no functional
  changes

- Patch 09 adds the address family independant NAT core and converts
  the existing IPv4-only NAT code to an AF-specific module

- Patches 10 and 11 add some infrastructure for IPv6 NAT

- Patch 12 adds IPv6 NAT support

- Patches 13-15 add IPv6 specific NAT targets

- Patches 16-19 add some IPv6-capable ports of existing NAT helpers

- Patch 19 is independant of the IPv6 NAT code and adds support for
  stateless IPv6 prefix translation, just to relieve my conscience ;)


Since the last posting numerous bugs have been fixed, I don't remember
all of them, the more important ones include:

- automatic NAT module loading in ctnetlink

- address selection when mapping to IPv6 ranges

- handling of IPv6 fragments

- NAT handling of ICMPv6 error messages

Besides implementing IPv6 NAT, there are no known bugs left. Userspace
patches will follow shortly.

The entire patchset is also available at

git://github.com/kaber/nf-nat-ipv6.git master

Comments, questions and test results welcome.
