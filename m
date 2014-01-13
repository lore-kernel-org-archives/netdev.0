From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] path mtu hardening patches
Date: Mon, 13 Jan 2014 14:12:55 -0800 (PST)
Message-ID: <20140113.141255.1630640968086469722.davem@davemloft.net>
References: <CABrhC0=9ff8aLG4y4gxiGrGBBHvdcWD2pCC3wyLTveKHRySg4A@mail.gmail.com>
	<20140113212808.GJ6586@order.stressinduktion.org>
	<CABrhC0=CfPxB7rNrA0ukfZyNLuTNSBB2srohr-Yt2b4k6oHWxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com, fweimer@redhat.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbaAMWM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:12:59 -0500
In-Reply-To: <CABrhC0=CfPxB7rNrA0ukfZyNLuTNSBB2srohr-Yt2b4k6oHWxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Heffner <johnwheffner@gmail.com>
Date: Mon, 13 Jan 2014 16:50:38 -0500

> Perhaps I misunderstood your description of FreeBSD then.  It seems
> hard for me to believe that MTU discovery for UDP is broken by default
> in FreeBSD.  It was not as of a couple years ago...

FreeBSD never implemented PMTU for anything other than TCP.

In fact, outside of Linux and perhaps Solaris, very few networking
stacks have implemented UDP PMTU.
