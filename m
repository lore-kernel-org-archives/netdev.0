From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: remove a call to skb_queue_len() in inet_diag.c
Date: Sun, 04 Feb 2007 12:23:48 -0800 (PST)
Message-ID: <20070204.122348.38681159.davem@davemloft.net>
References: <Pine.LNX.4.64.0612311547200.30821@localhost.localdomain>
	<20070204142921.GA5787@unknown-00-0d-60-79-ca-00.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: t.hisch@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41759
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752538AbXBDUXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 15:23:49 -0500
In-Reply-To: <20070204142921.GA5787@unknown-00-0d-60-79-ca-00.lan>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Hisch <t.hisch@gmail.com>
Date: Sun, 4 Feb 2007 15:29:21 +0100

> remove unneeded call to skb_queue_len (skb_dequeue already checks queuelen) and
> replace a sizeof() by a Netlink Macro
> 
> Signed-off-by: Thomas Hisch <t.hisch@gmail.com>

You don't understand the code you are editing :-)

We want to process the number of packets present when we
start the function, other threads can add more packets to
the queue meanwhile and we don't want to keep dequeueing
in that case or else we can theoretically run forever with
a fast enough producer.

Also, please post all networking patches to netdev@vger.kernel.org,
the majority of the networking developers do not read linux-kernel.

Thank you.
