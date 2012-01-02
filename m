From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libmnl 1.0.2 release
Date: Mon, 2 Jan 2012 19:55:36 +0100
Message-ID: <20120102185536.GA26679@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0F1p//8PRICkK4MW"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org, lwn@lwn.net,
	netfilter-announce@lists.netfilter.org
To: Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project presents libmnl-1.0.0

libmnl is a minimalistic user-space library oriented to Netlink
developers. There are a lot of common tasks in parsing, validating,
constructing of both the Netlink header and TLVs that are repetitive
and
easy to get wrong. This library aims to provide simple helpers that
allows you to re-use code and to avoid re-inventing the wheel.

This library is released under LGPLv2+.

Features:
* Small: the shared library requires around 45KB for an x86-based
* computer.
* Simple: this library avoids complexity and elaborated abstractions
that tend to hide Netlink details.
* Easy to use: the library simplifies the work for Netlink-wise
developers. It provides functions to make socket handling, message
building, validating, parsing and sequence tracking, easier.
* Easy to re-use: you can use the library to build your own
* abstraction
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

--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libmnl-1.0.2.txt"

Jan Engelhardt (11):
      build: use AM_CPPFLAGS
      build: use only AC_CANONICAL_HOST
      examples/genl: fix newline imbalance
      examples/genl: support dumping the genl families
      src: use limits.h header
      include: use sanitized header from headers_install
      build: abort autogen on subcommand failure
      Update .gitignore
      build: use AC_CONFIG_AUX_DIR and stash away tools
      m4: resolve autoconf-2.68 warnings
      build: disable implicit .tar.gz archive generation and use POSIX mode

Pablo Neira Ayuso (8):
      header: fix invalid use of type void * in arithmetic of mnl_for_each_nest(...)
      Merge branch 'master' of git://dev.medozas.de/libmnl
      doc: don't show up EXPORT_SYMBOL in doxygen
      doxygen: exclude EXPORT_SYMBOL and skip .git files
      COPYING: update file (FSF address was outdated)
      build: kernel-like compilation messages
      example: release them in the public domain
      build: libmnl 1.0.2 release

Sean Robinson (1):
      doc: fix wrong comment describing mnl_nlmsg_batch_stop()


--0F1p//8PRICkK4MW--
