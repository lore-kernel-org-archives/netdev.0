From: Andrei Warkentin <andrey.warkentin@gmail.com>
Subject: NetKGDB suport.
Date: Fri, 24 Feb 2012 21:44:09 -0500
Message-ID: <1330137851-4716-1-git-send-email-andrey.warkentin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:47051 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157Ab2BYDo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 22:44:28 -0500
Received: by qafk1 with SMTP id k1so611370qaf.19
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2012 19:44:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is tentative patch set I am sending for feedback. It
implements a network I/O backend for KDB/KGDB, the kernel
debugger. I sent this patch set to linux-kernel, and was
kindly referred to this list by David Miller as the right
place for feedback.

NetKGDB is very similar to netconsole, on which it is based, but with
a crucial difference - netkgdb is designed to accept connections
from any hosts, i.e. it is not necessary to specify these ahead
of time. This makes it that much more useful in a "this host crashed
and a I want a developer to take a look at it" scenario, common to
large scale test/QA farms and automated testing harnesses. This
involves a minor change to the netpoll rx_hook, namely, to provide
source connection information.

[PATCH 1/2] NETPOLL: Extend rx_hook support.
[PATCH 2/2] NETKGDB: Ethernet/UDP/IP KDB transport.

Thanks,
A
