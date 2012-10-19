From: Li Yu <raise.sail@gmail.com>
Subject: [PATCH 0/3] skbtrace v2: A trace infrastructure for networking subsystem
Date: Fri, 19 Oct 2012 14:16:04 +0800
Message-ID: <5080F024.30608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:56761 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263Ab2JSGQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 02:16:14 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so121597pad.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 23:16:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

  This patch set introduces to the tracing infrastructure for networking
subsystem, they are based on v3.6 source code.

  The changes from last version (v1):

  1. IPv4 mapped IPv6 sockets support, I found many applications use
     this mean to live on double stack environment.
  2. The BPF filter for connection based events, skbtrace constructs
     a temporarily sk_buff to run BPF program.
  3. Add three TCP trace events for RTTM, show active connection
     information, TCP internal timers. and show more states in
     tcp_ca_state event.
  4. Introduce to primary and secondary event support. That is secondary
     event only would be exported after its primary event is triggered.
     This could be used for reduce gathered trace points more, we can
     see this is another kind of trace point filter.
  5. Userland utility modularizaion.
  6. Code refactoring and bug fixes.

  I am going to add some sk_buff based events in next version (v3), so
we will could know such like how a sk_buff pass stack, how long it stay
in stack, how TSO/GSO/SACK/... split/merge them, and so on.

  You can get whole kernel source tree at github:

	https://github.com/Rover-Yu/skbtrace-userland
	https://github.com/Rover-Yu/skbtrace-kernel

  Welcome for suggestions.

  Thanks.

Yu
