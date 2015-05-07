From: <richard.alpe@ericsson.com>
Subject: [PATCH iproute2] tipc: introduce TIPC configuration tool
Date: Thu, 7 May 2015 15:07:35 +0200
Message-ID: <1431004056-6282-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:59974 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbEGNLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 09:11:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

This is the new tipc tool that utilizes the relativly new TIPC netlink API in
the kernel. Introducing this tool into iproute2 has been discussed previously.

For more information about the design decisions of this tool, see the README
file.

There isn't yet a manpage for the this tool. I will start to write one once I
submitted this for review.

Richard Alpe (1):
  tipc: add new TIPC configuration tool

 Makefile         |   2 +-
 tipc/.gitignore  |   1 +
 tipc/Makefile    |  19 ++
 tipc/README      |  63 +++++
 tipc/bearer.c    | 725 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tipc/bearer.h    |  22 ++
 tipc/cmdl.c      | 127 ++++++++++
 tipc/cmdl.h      |  46 ++++
 tipc/link.c      | 520 +++++++++++++++++++++++++++++++++++++++
 tipc/link.h      |  21 ++
 tipc/media.c     | 260 ++++++++++++++++++++
 tipc/media.h     |  21 ++
 tipc/misc.c      |  35 +++
 tipc/misc.h      |  19 ++
 tipc/msg.c       | 170 +++++++++++++
 tipc/msg.h       |  20 ++
 tipc/nametable.c | 109 +++++++++
 tipc/nametable.h |  21 ++
 tipc/node.c      | 267 ++++++++++++++++++++
 tipc/node.h      |  21 ++
 tipc/socket.c    | 140 +++++++++++
 tipc/socket.h    |  21 ++
 tipc/tipc.c      |  96 ++++++++
 23 files changed, 2745 insertions(+), 1 deletion(-)
 create mode 100644 tipc/.gitignore
 create mode 100644 tipc/Makefile
 create mode 100644 tipc/README
 create mode 100644 tipc/bearer.c
 create mode 100644 tipc/bearer.h
 create mode 100644 tipc/cmdl.c
 create mode 100644 tipc/cmdl.h
 create mode 100644 tipc/link.c
 create mode 100644 tipc/link.h
 create mode 100644 tipc/media.c
 create mode 100644 tipc/media.h
 create mode 100644 tipc/misc.c
 create mode 100644 tipc/misc.h
 create mode 100644 tipc/msg.c
 create mode 100644 tipc/msg.h
 create mode 100644 tipc/nametable.c
 create mode 100644 tipc/nametable.h
 create mode 100644 tipc/node.c
 create mode 100644 tipc/node.h
 create mode 100644 tipc/socket.c
 create mode 100644 tipc/socket.h
 create mode 100644 tipc/tipc.c

-- 
2.1.4
