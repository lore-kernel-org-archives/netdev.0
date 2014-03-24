From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3
 buffer overflows triggered by hardware devices
Date: Mon, 24 Mar 2014 14:35:12 -0400 (EDT)
Message-ID: <20140324.143512.68893694230434555.davem@davemloft.net>
References: <CAKPWWNFZc8v04-GM5Ttoa-CW_zhNmfMCYO2Q-Yh-75qitSUpiA@mail.gmail.com>
	<20140324.131733.723749970605014851.davem@davemloft.net>
	<CAKPWWNF982P7PtuoySy6ncU1mCNFm2RBMEDKr3-QKoCKU-6AMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@aculab.com, netdev@vger.kernel.org,
	grantgrundler@gmail.com
To: alon@privatecore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbaCXSfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 14:35:17 -0400
In-Reply-To: <CAKPWWNF982P7PtuoySy6ncU1mCNFm2RBMEDKr3-QKoCKU-6AMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alon Nafta <alon@privatecore.com>
Date: Mon, 24 Mar 2014 10:35:37 -0700

> Moreover, a system can be protected from malicious HW, and in fact
> doesn't have to trust HW at all (except for the CPU obviously).

So should we check to make sure the program counter of the cpu really
increments to the next instruction every time?

There is a limit to everything.

The length field of DMA descriptors is absolutely, fully, trusted in
the vast majority of drivers.
