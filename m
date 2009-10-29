From: David Miller <davem@davemloft.net>
Subject: Re: iproute uses too small of a receive buffer
Date: Thu, 29 Oct 2009 01:17:50 -0700 (PDT)
Message-ID: <20091029.011750.112668278.davem@davemloft.net>
References: <20091027162434.6dc31b2d@nehalam>
	<4AE7F859.7020105@gmail.com>
	<4AE895E8.60308@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753208AbZJ2IR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 04:17:26 -0400
In-Reply-To: <4AE895E8.60308@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 28 Oct 2009 20:05:12 +0100

> How about this? It will double the receive queue limit on ENOBUFS
> up to 1024 * 1024b, then bail out with the normal error message on
> further ENOBUFS.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: David S. Miller <davem@davemloft.net>
