From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libmnl 1.0.4 release
Date: Sat, 2 Jul 2016 11:11:42 +0200
Message-ID: <20160702091142.GA2457@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Content-Transfer-Encoding: 8bit
Cc: lwn@lwn.net
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46746 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128AbcGBJLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jul 2016 05:11:49 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 4E935E8E8A
	for <netdev@vger.kernel.org>; Sat,  2 Jul 2016 11:11:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3DB8B9EBB2
	for <netdev@vger.kernel.org>; Sat,  2 Jul 2016 11:11:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A3ECD6449E
	for <netdev@vger.kernel.org>; Sat,  2 Jul 2016 11:11:43 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project presents:

        libmnl 1.0.4

libmnl is a minimalistic user-space library oriented to Netlink
developers. There are a lot of common tasks in parsing, validating,
constructing of both the Netlink header and TLVs that are repetitive
and easy to get wrong. This library aims to provide simple helpers
that allows you to re-use code and to avoid re-inventing the wheel.

This release comes with improvements in the netlink message printing
function, attribute validation for MNL_TYPE_MSEC and MNL_TYPE_U64,
clang compilation fixes, the new mnl_socket_open2() and
mnl_socket_fdopen() functions, missing handling for NLM_F_DUMP_INTR
and documentation updates.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/libmnl/downloads.html
ftp://ftp.netfilter.org/pub/libmnl/

Have fun!

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="changes-libmnl-1.0.4.txt"
Content-Transfer-Encoding: 8bit

Carlos Falgueras García (1):
      nlmsg: Improve payload printing

Eric Leblond (1):
      doxygen: fix a variable name.

Felix Janda (1):
      examples/netfilter: Include <endian.h> for be64toh

Guillaume Nault (1):
      socket: introduce mnl_socket_open2()

Gustavo Zacarias (1):
      configure: uclinux is also linux

Hisao Tanabe (1):
      attr: minor doc fix in mnl_attr_next()

Ken-ichirou MATSUZAWA (9):
      examples: set attr table
      examples: fix trivial error message
      examples: use mnl_nlmsg_get_payload()
      attr: validate MNL_TYPE_MSEC same as MNL_TYPE_U64
      examples: made sub functions the same
      examples: fix display condition
      examples: use mnl_socket_setsockopt
      socket: creating a struct mnl_socket from a pre-existing socket
      doc: minor fix

Markus Teich (1):
      header: use sysconf() instead of getpagesize()

Pablo Neira Ayuso (18):
      examples: add genl-group-events
      examples: add kobject-event
      examples: rtnl-route-add improvements (including IPv6 support)
      examples: rtnl-route-event: add example to listen to IPv4/IPv6 routes
      examples: rtnl-route-event: update Makefile.am
      examples: rtnl-route-add: fix typo in IPv6 support
      examples: rtnl-route-dump: display also metric/priority
      examples: rtnl-link-dump: display HW address
      examples: add rtnl-addr-dump
      examples: netfilter: add nfct-dump
      include: cache copy of nfnetlink_conntrack.h
      examples: netfilter: add nfct daemon skeleton code
      include: don't force compiler to enter C++11 mode
      include: cache copy of include/linux/socket.h
      socket: calloc expects struct size as second parameter
      example: netfilter: get rid of aligned_be64 definitions
      src: cleanup function definitions
      build: libmnl 1.0.4 release

Peter Foley (1):
      Move declaration of visibility attributes before definition.

Philip Prindeville (1):
      examples: rtnl-route-dump: add IPv6 support

Shawn Landden (1):
      doc: mnl_socket_open returns NULL on error

Stephen Hemminger (2):
      headers: update netlink.h to 3.9
      callback: fix missing handling of NLM_F_DUMP_INTR


--CE+1k2dSO48ffgeK--
