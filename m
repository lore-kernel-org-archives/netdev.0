From: David Miller <davem@davemloft.net>
Subject: Re: Piggyback the final ACK of the three way TCP connection
 establishment with the data
Date: Thu, 22 Mar 2012 19:07:04 -0400 (EDT)
Message-ID: <20120322.190704.1413241913108331963.davem@davemloft.net>
References: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
	<1332374452.9433.15.camel@edumazet-glaptop>
	<CAK3+h2ydKQ15U1_2dqWsHAL_LKYm-1xbJvUbeaMJShoOCU_TsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: vincent.mc.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756364Ab2CVXHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:07:08 -0400
In-Reply-To: <CAK3+h2ydKQ15U1_2dqWsHAL_LKYm-1xbJvUbeaMJShoOCU_TsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Li <vincent.mc.li@gmail.com>
Date: Thu, 22 Mar 2012 16:02:41 -0700

> but on Linux, do I need to change wu-ftpd code and modify the socket
> option with TCP_DEFER_ACCEPT or TCP_QUICKACK in order to trigger the
> code snippet in tcp_rcv_synsent_state_process?

Yes.
