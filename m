From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next 0/6] Ability to peek full socket queue
Date: Tue, 21 Feb 2012 21:30:06 +0400
Message-ID: <4F43D49E.3010401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1312 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225Ab2BURaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 12:30:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

This is an attempt to implement the ability to read socket's queue without
removing skbs from it. Using MSG_PEEK doesn't work for unix sockets, both
dgram and stream.

The proposal is to implement the SO_PEEK_OFF sockopt which specifies an
offset in bytes where to start peeking the data from.

I've already sent an example of how this can look, and since nobody objected
about the concept itself, here's the "official" v1. This includes all the unix
socket types and (hopefully) addresses locking issues David pointed out.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
