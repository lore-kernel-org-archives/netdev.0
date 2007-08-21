From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Don't do netpoll on per cpu backlog napi struct
Date: Tue, 21 Aug 2007 16:19:46 -0700 (PDT)
Message-ID: <20070821.161946.129058975.davem@davemloft.net>
References: <20070821230851.GP32236@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34136
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752932AbXHUXTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 19:19:48 -0400
In-Reply-To: <20070821230851.GP32236@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 01:08:51 +0200

> The per cpu backlog napi struct can't do netpoll and has the
> dev member set to NULL. Fixes an oops on boot when netpoll is
> enabled.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks a lot Thomas.
