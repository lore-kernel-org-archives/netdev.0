From: Joe Damato <joe@boundary.com>
Subject: [PATCH 0/2] connector: Add proc_events for connect/accept
Date: Mon,  1 Aug 2011 11:04:23 -0700
Message-ID: <1312221865-3012-1-git-send-email-joe@boundary.com>
Cc: netdev@vger.kernel.org, Joe Damato <joe@boundary.com>
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:37686 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab1HAS2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 14:28:09 -0400
Received: by gxk21 with SMTP id 21so3615381gxk.19
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2011 11:28:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

It would be extremely useful to have a simple way of mapping pids to network
connections without having to create piles of inotify watches in /proc/ and
/proc/<pid>/fd/ and then search for corresponding inode numbers in
/proc/net/{tcp, udp, ... }.

I've added two simple connector events so that monitoring processes using
connector can get a notification of successful calls to connect/accept. This
allows a monitoring process to be aware of network connections without having
to jump through the inotify+proc parsing hoops.

Thanks,
Joe

Joe Damato (2):
  Create a new connector proc_event for successful calls to connect.
  Create a new connector proc_event for successful calls to accept.

 drivers/connector/cn_proc.c |   70 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/cn_proc.h     |   39 +++++++++++++++++++++++-
 net/socket.c                |    9 +++++
 3 files changed, 117 insertions(+), 1 deletions(-)

-- 
1.7.4.1

