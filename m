From: David Miller <davem@davemloft.net>
Subject: Re: Receive offloads, small RCVBUF and zero TCP window
Date: Mon, 28 Nov 2016 15:54:59 -0500 (EST)
Message-ID: <20161128.155459.1527519991492144879.davem@davemloft.net>
References: <2080597.A38JFJZ1AD@zbook>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexandre.sidorenko@hpe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41794 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753005AbcK1UzB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:55:01 -0500
In-Reply-To: <2080597.A38JFJZ1AD@zbook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Date: Mon, 28 Nov 2016 15:49:26 -0500

> Now the question is whether is is OK to have icsk->icsk_ack.rcv_mss
> larger than MTU.

It absolutely is not OK.

If VMWare wants to receive large frames for batching purposes it must
use GRO or similar to achieve that, not just send vanilla frames into
the stack which are larger than the device MTU.
