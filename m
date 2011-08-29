From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next ] Fix time-lag of IFF_RUNNING flag consistency
 between vlan and real devices
Date: Mon, 29 Aug 2011 02:34:08 -0400 (EDT)
Message-ID: <20110829.023408.440980195220010292.davem@davemloft.net>
References: <1314540589.3036.12.camel@edumazet-laptop>
	<f6ded72b-346d-43af-af47-4edae5060406@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	kaber@trash.net, mirq-linux@rere.qmqm.pl, therbert@google.com,
	jesse@nicira.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com,
	mitsuo.hayasaka.hu@hitachi.com
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039Ab1H2Gfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 02:35:31 -0400
In-Reply-To: <f6ded72b-346d-43af-af47-4edae5060406@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Sun, 28 Aug 2011 23:06:28 -0700 (PDT)

> This was mostly typical of older hardware that did not have a PHY
> interrupt.

Many have to poll because the PHY interrupt is simply unreliable.
