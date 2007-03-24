From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 0/3]: Further reduction of direct access to skb->data
Date: Sat, 24 Mar 2007 18:07:06 -0300
Message-ID: <20070324210706.GV17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:32980 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320AbXCXVHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 17:07:30 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1706058wxd
        for <netdev@vger.kernel.org>; Sat, 24 Mar 2007 14:07:29 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

	Please take a look, at first I thought about adding a skb_copy_{from,to}_data,
that would do just the memcpy, but then skb_{copy,store}_bits seems to be fit for this
purpose, but its more costly in some cases, comments?

	Available at:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22

- Arnaldo
