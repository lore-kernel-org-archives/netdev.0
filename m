From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] net: replace NIPQUAD() in net/netfilter/
Date: Mon, 03 Nov 2008 17:10:16 -0800 (PST)
Message-ID: <20081103.171016.207053544.davem@davemloft.net>
References: <1225412025.5574.34.camel@brick>
	<43ca39800811030856u5acf9601s6aef81887f19f859@mail.gmail.com>
	<1225734196.5361.5.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julius.volz@gmail.com, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52768
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753918AbYKDBKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 20:10:41 -0500
In-Reply-To: <1225734196.5361.5.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Mon, 03 Nov 2008 09:43:16 -0800

> [PATCH] printk: ipv4 address digits printed in reverse order
> 
> put_dec_trunc prints the digits in reverse order and is reversed
> inside number(). Continue using put_dec_trunc, but reverse each quad
> in ip4_addr_string.
> 
> [Noticed by Julius Volz]
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks for fixing this Harvey, and thanks to
Julius for the report and testing the fix.
