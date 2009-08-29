From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: ip_rt_send_redirect() optimization
Date: Fri, 28 Aug 2009 23:52:11 -0700 (PDT)
Message-ID: <20090828.235211.59890287.davem@davemloft.net>
References: <4A92C434.1080406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36232
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751835AbZH2Gv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:51:57 -0400
In-Reply-To: <4A92C434.1080406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Aug 2009 18:47:48 +0200

> While doing some forwarding benchmarks, I noticed ip_rt_send_redirect() is rather
> expensive, even if send_redirects is false for the device.
> 
> Fix is to avoid two atomic ops, we dont really need to take a reference on in_dev
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
