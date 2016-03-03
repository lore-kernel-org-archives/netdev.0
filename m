From: Ed Schouten <ed@nuxi.nl>
Subject: [PATCH 0/3] UNIX sockets: POSIX conformance of errno's
Date: Thu,  3 Mar 2016 12:23:36 +0100
Message-ID: <1457004216-24988-1-git-send-email-ed@nuxi.nl>
Cc: Ed Schouten <ed@nuxi.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37300 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755735AbcCCLXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 06:23:40 -0500
Received: by mail-wm0-f47.google.com with SMTP id p65so27273802wmp.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 03:23:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

While comparing the behavior of the Berkeley sockets API different
operating systems, I noticed that in some places we return different
errno's as what POSIX requires and how other systems work, but also what
we document in our own man pages.

This is the first time I'm sending a patch to the Linux kernel, so if
there's anything wrong with the way I submitted these patches, just let
me know.

Thanks,
Ed

Ed Schouten (3):
  Make listen() on an unbound UNIX socket return EDESTADDRREQ.
  Let open() on a UNIX socket return EOPNOTSUPP.
  Return ENOTCONN when trying to recv() on an unconnected UNIX socket.

 fs/inode.c         | 13 ++++++++++++-
 net/unix/af_unix.c |  6 +++---
 2 files changed, 15 insertions(+), 4 deletions(-)

-- 
2.5.0
