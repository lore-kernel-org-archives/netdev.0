From: Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp>
Subject: What does -EIOCBQUEUED do?
Date: Mon, 13 Aug 2007 22:27:57 +0900
Message-ID: <200708132227.DBJ15225.OGtFSPUFNWE@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:62882 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S944396AbXHMOAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 10:00:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

There are several locations that handle
-EIOCBQUEUED error code.
According to include/linux/errno.h ,
it seems this code is NFS related and
caller will receive completion event later.
But I couldn't figure out where is the beginning point
and what is happening.

What functions are called before aio_complete() is called?
(For example, is udp_recvmsg() called if sock_recvmsg() for
UDP socket returned -EIOCBQUEUED?)

What memory regions are accessed before aio_complete() is called?
(For example, is "struct msghdr"->msg_name accessed
if sock_recvmsg() for UDP socket returned -EIOCBQUEUED?)

Regards.
