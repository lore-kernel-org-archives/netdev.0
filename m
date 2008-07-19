From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATC] sctp: various fixes
Date: Sat, 19 Jul 2008 00:26:45 -0400
Message-ID: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:38475 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbYGSE2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 00:28:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

This is a bunch of SCTP fixes that have accumlated over the past week or
so. 

Here is the shortlog:

Florian Westphal (2):
      sctp: Don't abort initialization when CONFIG_PROC_FS=n
      sctp: Prevent uninitialized memory access

Harvey Harrison (1):
      sctp: remove unnecessary byteshifting, calculate directly in big-endian

Vlad Yasevich (4):
      sctp: Support ipv6only AF_INET6 sockets.
      sctp: Do not leak memory on multiple listen() calls
      sctp: Allow only 1 listening socket with SO_REUSEADDR
      sctp: Update sctp global memory limit allocations.

Please apply.  Thanks
-vlad
