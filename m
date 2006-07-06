From: Beschorner Daniel <Daniel.Beschorner@facton.com>
Subject: SKB BUG: Invalid truesize
Date: Thu, 6 Jul 2006 14:53:45 +0200
Message-ID: <BB1F4EFD574E9F409035BDA71C9612500242B8@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-owner@vger.kernel.org>
Received: from loewe.unit-netz.de ([212.202.148.42]:60548 "EHLO
	loewe.unit-netz.de") by vger.kernel.org with ESMTP id S1030236AbWGFMxO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 08:53:14 -0400
Received: from exchange.i-bn (exchange [192.168.100.120])
	by loewe.unit-netz.de (8.13.3/8.13.3/Unit) with ESMTP id k66Cr9Y7008336
	for <netdev@vger.kernel.org>; Thu, 6 Jul 2006 14:53:09 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Does it harm?

SKB BUG: Invalid truesize (380) len=1383, sizeof(sk_buff)=156
SKB BUG: Invalid truesize (316) len=1383, sizeof(sk_buff)=156
SKB BUG: Invalid truesize (348) len=1383, sizeof(sk_buff)=156
SKB BUG: Invalid truesize (316) len=1383, sizeof(sk_buff)=156
SKB BUG: Invalid truesize (380) len=1383, sizeof(sk_buff)=156

I found it in the log of a 2.6.17 box using IPSEC tunnels.
