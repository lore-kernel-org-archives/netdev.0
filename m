From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Shaping TCP ACK packets
Date: Mon, 05 Dec 2011 23:18:03 -0500 (EST)
Message-ID: <7cf7b0f6-b30f-465a-9e50-20bd2c31bbe9@jasiiieee>
References: <b7c7ae97-0030-4397-a1e3-ec29babdff4d@jasiiieee>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:50807 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756454Ab1LFDRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 22:17:40 -0500
In-Reply-To: <b7c7ae97-0030-4397-a1e3-ec29babdff4d@jasiiieee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I've seen several sites recommend prioritizing TCP ACK packets using tc.  Is that a good idea? I have two reservations:

1) If my line is congested, isn't delaying ACKs a good way to slow down the conversation? Accelerating ACKs under congestion sounds a bit like stuffing more food in my mouth when I'm already choking.

2) By messing with normal coordination of TCP, do I risk making a mess.  Specifically, can I create problems with out of order packet delivery - send an ACK before the packet which should have preceded it? I suppose in a well behaved protocol that wouldn't happen but I'm not sure.  Thanks - John
