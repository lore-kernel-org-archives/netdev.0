From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] net-tcp: TCP/IP stack bypass for loopback
 connections.
Date: Tue, 20 Dec 2011 15:19:30 -0500 (EST)
Message-ID: <20111220.151930.911300602237271546.davem@davemloft.net>
References: <20111220193614.0733F160AA8@brutus.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brutus@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab1LTUTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 15:19:33 -0500
In-Reply-To: <20111220193614.0733F160AA8@brutus.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce "Brutus" Curtis <brutus@google.com>
Date: Tue, 22 Nov 2011 16:09:33 -0800

> TCP/IP loopback socket pair stack bypass, based on an idea by, and
> rough upstream patch from, David Miller <davem@davemloft.net> called
> "friends", the data structure modifcations and connection scheme are
> reused with new dedicated code for the data path.

Thanks for doing this work.

It's very disappoing that the whole of the data sending system
calls need to be duplicated into this new tcp_friends.c file.

My entire hope was that we could integrate the logic into the
existing sendmsg/recvmsg implementations.

Please reimplement things this way.  With so much code duplication
I really cannot justify putting this feature in as-is.
