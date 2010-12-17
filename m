From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libmnl 1.0.0 release
Date: Fri, 17 Dec 2010 15:20:51 +0100
Message-ID: <4D0B71C3.7030806@netfilter.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020206060701090905080306"
Cc: netfilter@vger.kernel.org, netfilter-announce@lists.netfilter.org,
	lwn@lwn.net, Linux Netdev List <netdev@vger.kernel.org>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020206060701090905080306
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi!

The Netfilter project presents libmnl-1.0.0

libmnl is a minimalistic user-space library oriented to Netlink
developers. There are a lot of common tasks in parsing, validating,
constructing of both the Netlink header and TLVs that are repetitive and
easy to get wrong. This library aims to provide simple helpers that
allows you to re-use code and to avoid re-inventing the wheel.

This library is released under LGPLv2+.

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

--------------020206060701090905080306
Content-Type: text/plain;
 name="changes-libmnl-1.0.0.txt"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
 filename="changes-libmnl-1.0.0.txt"

Cristian Rodríguez (1):
      src: implement both GCC visibility support and export script

Jan Engelhardt (36):
      build: just use autoreconf
      build: do not abuse AM_INIT_AUTOMAKE for autoconf options
      build: automake options should be in AM_INIT_AUTOMAKE
      build: use subdir-objects and CC_C_O
      build: run autoupdate
      build: rebuild .pc files when configure status changed
      build: resolve compiler warnings
      build: remove unneeded -dynamic -ldl -nostartfiles flags
      build: default to not build static libraries
      Add .gitignore files
      build: fix disable_static functionality
      src: avoid using deprecated unspecified argument lists
      src: add const qualifiers
      src: remove redundant casts
      socket: remove statement with no effect
      doc: documentation updates
      include: consistent usage of "extern"
      attr: string functions should take char *
      callback: mnl_cb_run should use a void *
      socket: use more appropriate types for mnl_socket_bind
      include: add cplusplus guards for extern
      nlmsg: use bool return type for yes-no functions
      attr: rename str_null from NULL away
      examples: remove redundant casts
      build: remove -fPIC flag
      build: remove statements without obvious effect
      socket: constify a struct sockaddr_nl
      nlmsg: use bool for mnl_nlmsg_ok()
      attr: remove redundant check for NULL
      include: use C++ headers in C++ mode
      attr: avoid multiple definition of hidden variable
      socket: propagate sendto/recvmsg's return types
      Update .gitignore
      build: tag function headers rather than decls as exported
      ld: add some more precautionary CFLAGS
      nlmsg: remove unused function mnl_nlmsg_aligned_size()

Jozsef Kadlecsik (2):
      fix for mnl_attr_for_each_nested()
      fix mnl_attr_parse()

Pablo Neira Ayuso (75):
      initial libmnl import
      fix leak in mnl_socket_open()
      remove libnfnetlink stuff from autogen.sh
      finish API documentation
      fix mnl_cb_run() and mnl_cb_run2() return value logic
      add COPYING file
      use `unsigned int' for number of bytes and array size in callback API
      partially revert previous commit
      fix mnl_socket_bind() to support the selection of the netlink portID
      constify several mnl_socket_* parameters and use size_t instead of int
      use C99 types uintXX_t instead of POSIX u_intXX_t
      check portid of received messages in examples
      revert abcaad6b65ed368c13c353ed71619332f76d9c2a
      add validation infrastructure and rework attribute parsing
      check source of the netlink message and fix sequence tracking logic
      remove mnl_align() as it's been replaced by MNL_ALIGN()
      rename mnl_attr_type_invalid() by mnl_attr_type_ok()
      remove bogus checking in mnl_attr_validate() and mnl_attr_validate2()
      add -Wextra to spot more errors in compilation
      fix warning in compilation due to different signess
      rename mnl_attr_type_ok() by mnl_attr_type_valid() for consistency
      rename msg.c to nlmsg.c
      rename mnl_nlmsg_payload_size() to mnl_nlmsg_get_payload_len() for consistency
      x
      more consistency name issues: rename get_data*() to get_payload*()
      add new README file
      review documentation on netlink attribute helpers
      improve documentation of netlink message helpers
      remove bogus casting in mnl_nlmsg_get_payload_tail()
      remove mnl_nlmsg_get_len() function
      minor update in README (library is around 30KB here, not 20KB)
      update socket helper documentation
      add mnl_nlmsg_fprintf() function for debugging purposes
      review data types for input parameters of mnl_attr_*() functions
      use size_t to indicate the buffer size in mnl_cb_run*()
      remove redudant alignment in mnl_nlmsg_size()
      fix warning in mnl_cb_run2()
      add -Wextra -Wall for example files
      fix lots of compilation warnings in example files
      remove references to 'generic' in header file
      add rtnl-route-add.c to examples
      add helpers to nest attributes
      add licensing terms of example files
      add nf-queue.c example file for nfnetlink_queue
      statify function in nf-queue.c example
      change errno values for mnl_cb_run[2]()
      relax mnl_attr_type_valid() checkings and change errno value
      fix rtnl-link-dump3.c
      add nfct-event example
      nlmsg: use size_t instead of int for several input parameters
      socket: remove mnl_socket_sendmsg() and mnl_socket_recvmsg()
      examples: fix rtnl-set-link
      examples: fix byte-order in nfct-event
      build: add notice on how to update library API version
      skip PortID and sequence checking if zero
      add missing .gitignore file to m4/ directory
      examples: put examples files into specific directories
      doxygen documentation
      add quote from Thoureau to documentation
      src: define MNL_SOCKET_BUFFER_SIZE to 8192UL
      doc: git tree update (now at netfilter.org) and fix listing in doxygen
      examples: add nflog example
      nlmsg: rework mnl_nlmsg_fprintf
      Merge branch 'master' of git://dev.medozas.de/libmnl
      license: change licensing terms from GPLv2+ to LGPLv2.1+
      nlmsg: remove unexisting mnl_nlmsg_total_size
      add libmnl.map file to src/Makefile.am
      attr: add mnl_attr_nest_cancel()
      header: add MNL_ARRAY_SIZE(x)
      callback: use of inline in mnl_cb_run*() function
      attr: add put function that allows to check buffer size
      header: use getpagesize() for MNL_SOCKET_BUFFER_SIZE
      header: missing parenthesis in MNL_SOCKET_BUFFER_SIZE definition
      nlmsg: add new message batching infrastructure
      build: 1.0.0 release


--------------020206060701090905080306--
