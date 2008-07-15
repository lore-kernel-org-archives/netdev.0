From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/7] INET: toss struct net initialization
 around
Date: Mon, 14 Jul 2008 23:01:48 -0700 (PDT)
Message-ID: <20080714.230148.170193560.davem@davemloft.net>
References: <4871F2D8.8030502@openvz.org>
	<4871F434.3000104@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56769
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753217AbYGOGBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 02:01:47 -0400
In-Reply-To: <4871F434.3000104@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 07 Jul 2008 14:47:16 +0400

> Some places, that deal with ICMP statistics already have where
> to get a struct net from, but use it directly, without declaring
> a separate variable on the stack.
> 
> Since I will need this net soon, I declare a struct net on the 
> stack and use it in the existing places in a separate patch not 
> to spoil the future ones.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
