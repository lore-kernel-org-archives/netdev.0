From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tcp: Change return value of
 tcp_rcv_established()
Date: Wed, 04 Sep 2013 00:55:18 -0400 (EDT)
Message-ID: <20130904.005518.141492547473955259.davem@davemloft.net>
References: <1378236202-27486-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761399Ab3IDEzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 00:55:19 -0400
In-Reply-To: <1378236202-27486-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Tue,  3 Sep 2013 12:23:22 -0700

> tcp_rcv_established() returns only one value namely 0. We change the return
> value to void (as suggested by David Miller).
> 
> After commit 0c24604b (tcp: implement RFC 5961 4.2), we no longer send RSTs in
> response to SYNs. We can remove the check and processing on the return value of
> tcp_rcv_established().
> 
> We also fix jtcp_rcv_established() in tcp_probe.c to match that of
> tcp_rcv_established().
> 
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Applied.
