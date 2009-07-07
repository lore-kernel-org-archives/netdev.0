From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ipv6: correct return on ipv6_rcv() packet drop
Date: Mon, 06 Jul 2009 18:09:45 -0700 (PDT)
Message-ID: <20090706.180945.113737445.davem@davemloft.net>
References: <20090707065624.ee55809e.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: lk-netdev@lk-netdev.nosense.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55222
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753813AbZGGBJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 21:09:38 -0400
In-Reply-To: <20090707065624.ee55809e.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Date: Tue, 7 Jul 2009 06:56:24 +0930

> The routine ipv6_rcv() uses magic number 0 for a return when it drops a
> packet. This corresponds to NET_RX_SUCCESS, which is obviously
> incorrect. Correct this by using NET_RX_DROP instead.
> 
> ps. It isn't exactly clear who the IPv6 maintainers are, apologies if
> I've missed any.
> 
> Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>

Applied.
