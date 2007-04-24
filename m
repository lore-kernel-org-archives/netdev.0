From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] tcp: congestion control initialization
Date: Mon, 23 Apr 2007 22:34:42 -0700 (PDT)
Message-ID: <20070423.223442.34760751.davem@davemloft.net>
References: <20070424033117.873984872@linux-foundation.org>
	<20070424033316.957480198@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-founsation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33913
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161643AbXDXFef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 01:34:35 -0400
In-Reply-To: <20070424033316.957480198@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-founsation.org>
Date: Mon, 23 Apr 2007 20:31:18 -0700

> Change to defer congestion control initialization.
> 
> If setsockopt() was used to change TCP_CONGESTION before
> connection is established, then protocols that use sequence numbers
> to keep track of one RTT interval (vegas, illinois, ...) get confused.
> 
> Change the init hook to be called after handshake.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.

I'll look this over for backporting, thanks Stephen.
