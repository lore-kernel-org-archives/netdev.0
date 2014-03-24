From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3
 buffer overflows triggered by hardware devices
Date: Mon, 24 Mar 2014 13:17:33 -0400 (EDT)
Message-ID: <20140324.131733.723749970605014851.davem@davemloft.net>
References: <CAKPWWNHc8q-evx7TaTWX5SObd3iVm6YpFmepajRHgXmVgC713g@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E77C0@AcuExch.aculab.com>
	<CAKPWWNFZc8v04-GM5Ttoa-CW_zhNmfMCYO2Q-Yh-75qitSUpiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@aculab.com, netdev@vger.kernel.org,
	grantgrundler@gmail.com
To: alon@privatecore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbaCXRRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 13:17:38 -0400
In-Reply-To: <CAKPWWNFZc8v04-GM5Ttoa-CW_zhNmfMCYO2Q-Yh-75qitSUpiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alon Nafta <alon@privatecore.com>
Date: Mon, 24 Mar 2014 09:41:21 -0700

> In regards to your comment about hardware-induced problems, from a
> holistic point of view, IMHO any buffer overflow should get fixed.

I completely disagree with you.

If we had to accomodate every possible arbitrary mis-behavior of
hardware, the drivers would be so bloated as to be nearly unusable.
