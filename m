From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET] rtnetlink notification rework
Date: Tue, 15 Aug 2006 00:38:24 -0700 (PDT)
Message-ID: <20060815.003824.26965635.davem@davemloft.net>
References: <20060814213718.580598840@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33247
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965211AbWHOHiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:38:23 -0400
To: tgraf@suug.ch
In-Reply-To: <20060814213718.580598840@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 14 Aug 2006 23:37:18 +0200

> This patchset reworks rtnetlink notifications. Notification logic
> is fixed and gets hidden behind nlmsg_notify() and the rtnl socket
> is no longer directly accessed. All notification paths get
> appropriate error handling. NLM_F_ECHO support is added where it
> makes sense and no major surgery is required. Abuses of current->pid
> for netlink pids are fixed. An exception is made for users of
> rtnetlink_send() which will get converted in a second step as some
> bigger code change are required.

Really nice work Thomas.  All patches applied to net-2.6.19:

-extern struct sock *rtnl;
-
...
-struct sock *rtnl;
-
...
-EXPORT_SYMBOL(rtnl);

Let's party! :-)
