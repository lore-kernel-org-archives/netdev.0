From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/4] TCPCT part 1: initial SYN exchange
 with SYNACK data
Date: Wed, 14 Oct 2009 23:15:40 -0700 (PDT)
Message-ID: <20091014.231540.01186298.davem@davemloft.net>
References: <4AD6B31B.3060402@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48692
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753236AbZJOGPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 02:15:44 -0400
In-Reply-To: <4AD6B31B.3060402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Thu, 15 Oct 2009 01:28:59 -0400

> Pass optional function parameters associated with sending SYNACK.
> These parameters are not needed after sending SYNACK, and are not
> used for retransmission.  Avoids extending struct tcp_request_sock,
> and avoids allocating kernel memory.

This callback is generic and isn't designed to take opaque
data.  All the other arguments to this callback are strongly
typed, and this is on purpose.

You'll need to find another way to implement this.
