From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Tue, 20 Apr 2010 14:41:06 -0700 (PDT)
Message-ID: <20100420.144106.118596093.davem@davemloft.net>
References: <1271769404.7895.10.camel@edumazet-laptop>
	<4BCDB425.9050007@lastsummer.de>
	<1271775421.7895.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: franco@lastsummer.de, xiaosuo@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752301Ab0DTVlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 17:41:03 -0400
In-Reply-To: <1271775421.7895.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Apr 2010 16:57:01 +0200

> I know many applications using TCP on loopback, they are real :)

This is all true and I support your hashing patch and all of that.

But if we really want TCP over loopback to go fast, there are much
better ways to do this.

Eric, do you remember that "TCP friends" rough patch I sent you last
year that essentailly made TCP sockets over loopback behave like
AF_UNIX ones and just queue the SKBs directly to the destination
socket without doing any protocol work?

If we ever got that working, tbench performance would become
impressive :)
