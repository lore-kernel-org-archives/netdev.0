From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [NET] Do pmtu check in transport layer
Date: Sat, 24 Mar 2007 21:14:58 -0700 (PDT)
Message-ID: <20070324.211458.85418853.davem@davemloft.net>
References: <11746948063923-git-send-email-jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965025AbXCYEO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 00:14:59 -0400
In-Reply-To: <11746948063923-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Fri, 23 Mar 2007 20:06:44 -0400

> Check the pmtu check at the transport layer (for UDP, ICMP and raw), and
> send a local error if socket is PMTUDISC_DO and packet is too big.  This is
> actually a pure bugfix for ipv6.  For ipv4, it allows us to do pmtu checks
> in the same way as for ipv6.
> 
> Signed-off-by: John Heffner <jheffner@psc.edu>

Applied, thanks John.
