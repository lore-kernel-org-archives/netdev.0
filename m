From: David Miller <davem@davemloft.net>
Subject: sk->sk_socket
Date: Tue, 17 Jun 2008 03:25:11 -0700 (PDT)
Message-ID: <20080617.032511.240272543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48560
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754207AbYFQKZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 06:25:11 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 05AE0C8C18B
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 03:25:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For the curious, here are the only assignments to sk->sk_socket
remaining in the net-next-2.6 tree right now:

include/net/sock.h:	sk->sk_socket = NULL;
include/net/sock.h:	sk->sk_socket = parent;
net/core/sock.c:		newsk->sk_socket = NULL;
net/core/sock.c:	sk->sk_socket		=	sock;
