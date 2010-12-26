From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libmnl 1.0.1 release
Date: Sun, 26 Dec 2010 22:20:10 +0100
Message-ID: <4D17B18A.8020806@netfilter.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000403000406050301070907"
Cc: netfilter@vger.kernel.org, netfilter-announce@lists.netfilter.org,
	lwn@lwn.net, Linux Netdev List <netdev@vger.kernel.org>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60897 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752703Ab0LZVUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Dec 2010 16:20:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000403000406050301070907
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi!

The Netfilter project presents libmnl-1.0.1

libmnl is a minimalistic user-space library oriented to Netlink
developers. There are a lot of common tasks in parsing, validating,
constructing of both the Netlink header and TLVs that are repetitive and
easy to get wrong. This library aims to provide simple helpers that
allows you to re-use code and to avoid re-inventing the wheel.

This library is released under LGPLv2.1+.

Features:
* Small: the shared library requires around 45KB for an x86-based computer.
* Simple: this library avoids complexity and elaborated abstractions
that tend to hide Netlink details.
* Easy to use: the library simplifies the work for Netlink-wise
developers. It provides functions to make socket handling, message
building, validating, parsing and sequence tracking, easier.
* Easy to re-use: you can use the library to build your own abstraction
layer on top of this library.
* Decoupling: the interdependency of the main bricks that compose the
library is reduced, i.e. the library provides many helpers, but the
programmer is not forced to use them.

More info at:
http://www.netfilter.org/projects/libmnl/

Doxygen documentation at:
http://www.netfilter.org/projects/libmnl/doxygen/

You can download it via FTP at:
ftp://ftp.netfilter.org/pub/libmnl

Enjoy!


--------------000403000406050301070907
Content-Type: text/plain;
 name="changes-libmnl-1.0.1.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="changes-libmnl-1.0.1.txt"

Jan Engelhardt (1):
      include: add missing unistd.h

Pablo Neira Ayuso (5):
      examples: fix wrong group mask number in nfct-event
      doc: add new website at netfilter.org to doxygen
      headers: add local copy of linux/netlink.h to libmnl
      header: fix signess issues in MNL_SOCKET_BUFFER_SIZE
      build: libmnl 1.0.1 release


--------------000403000406050301070907--
