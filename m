From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Use correct peer adr when copying MD5 keys
Date: Mon, 20 Jul 2009 07:50:36 -0700 (PDT)
Message-ID: <20090720.075036.39164841.davem@davemloft.net>
References: <1247756691.7627.5.camel@Maple>
	<20090716113652.65dd1c8d@nehalam>
	<1247858602.8509.7.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	agl@imperialviolet.org, yoshfuji@linux-ipv6.org
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52767
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751305AbZGTOub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:50:31 -0400
In-Reply-To: <1247858602.8509.7.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Fri, 17 Jul 2009 19:23:22 +0000

> [PATCH] tcp:  Use correct peer adr when copying MD5 keys
> 
> When the TCP connection handshake completes on the passive
> side, a variety of state must be set up in the "child" sock,
> including the key if MD5 authentication is being used.  Fix TCP
> for both address families to label the key with the peer's
> destination address, rather than the address from the listening
> sock, which is usually the wildcard.
> 
> Reported-by:   Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

Also applied, thanks!
