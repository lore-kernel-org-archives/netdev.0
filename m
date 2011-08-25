From: David Miller <davem@davemloft.net>
Subject: Re: [omega-g1:11110] Re: [PATCH] net: configurable sysctl
 parameter "net.core.tcp_lowat" for sk_stream_min_wspace()
Date: Wed, 24 Aug 2011 22:00:16 -0700 (PDT)
Message-ID: <20110824.220016.781758659534965980.davem@davemloft.net>
References: <4E51A3F0.5010500@ctc-g.co.jp>
	<20110822.113544.28950168095176936.davem@davemloft.net>
	<4E55D3C2.40308@ctc-g.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, omega-g1@ctc-g.co.jp,
	notsuki@redhat.com, motokazu.kozaki@hp.com, htaira@redhat.com,
	netdev@vger.kernel.org, tomohiko.takahashi@ctc-g.co.jp,
	kotaro.sakai@ctc-g.co.jp, ken.sugawara@ctc-g.co.jp
To: jun.kondo@ctc-g.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747Ab1HYFAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 01:00:33 -0400
In-Reply-To: <4E55D3C2.40308@ctc-g.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jun.Kondo" <jun.kondo@ctc-g.co.jp>
Date: Thu, 25 Aug 2011 13:46:58 +0900

> Currently, once the transmission buffer becomes full, it is not
> possible to write again unless there is one third of free space
> in the transmission buffer.

Then use a non-blocking socket if you don't want to block.

We're talking in circles, and will walk down the same discussions
again.  You have still not shown what real limitation is created
by the way things work currently.

I've said everything that I can, and I will thus recuse myself from
the rest of this discussion since I really can't add anything more.
