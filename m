From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: Show timer resolution instead of clock resolution
 in /proc/net/psched
Date: Wed, 10 Oct 2007 16:33:12 -0700 (PDT)
Message-ID: <20071010.163312.67413297.davem@davemloft.net>
References: <470CE2F0.20103@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751024AbXJJXdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 19:33:10 -0400
In-Reply-To: <470CE2F0.20103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 10 Oct 2007 16:34:24 +0200

> [NET_SCHED]: Show timer resolution instead of clock resolution in /proc/net/psched
> 
> The fourth parameter of /proc/net/psched is supposed to show the timer resultion
> and is used by HTB userspace to calculate the necessary burst rate. Currently
> we show the clock resolution, which results in a too low burst rate when the
> two differ.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
