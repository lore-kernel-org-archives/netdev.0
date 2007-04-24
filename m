From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] tcp: congestion control API update
Date: Mon, 23 Apr 2007 22:35:12 -0700 (PDT)
Message-ID: <20070423.223512.01051027.davem@davemloft.net>
References: <20070424033117.873984872@linux-foundation.org>
	<20070424033317.129630701@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-founsation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33917
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161632AbXDXFfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 01:35:05 -0400
In-Reply-To: <20070424033317.129630701@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-founsation.org>
Date: Mon, 23 Apr 2007 20:31:20 -0700

> Do some simple changes to make congestion control API faster/cleaner.
> * use ktime_t rather than timeval
> * merge rtt sampling into existing ack callback
>   this means one indirect call versus two per ack.
> * use flags bits to store options/settings
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Nice work Stephen.

Applied, thanks a lot.
