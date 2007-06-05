From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Avoid duplicate netlink notification when changing link
 state
Date: Tue, 05 Jun 2007 16:04:09 -0700 (PDT)
Message-ID: <20070605.160409.25475294.davem@davemloft.net>
References: <20070605225452.GV521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53035
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764775AbXFEXDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 19:03:54 -0400
In-Reply-To: <20070605225452.GV521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 6 Jun 2007 00:54:53 +0200

> When changing the link state from userspace not affecting any other
> flags. Two duplicate notification are being sent, once as action
> in the NETDEV_UP/NETDEV_DOWN notification chain and a second time
> when comparing old and new device flags after the change has been
> completed. Although harmless, the duplicates should be avoided.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Thanks for fixing this, patch applied.
