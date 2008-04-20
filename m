From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: 5701 DMA corruption fix
Date: Sat, 19 Apr 2008 18:13:02 -0700 (PDT)
Message-ID: <20080419.181302.157459642.davem@davemloft.net>
References: <20080419005952.GB8729@localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net,
	tonyb@cybernetics.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53047
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753372AbYDTBNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 21:13:00 -0400
In-Reply-To: <20080419005952.GB8729@localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 18 Apr 2008 17:59:52 -0700

> Herbert Xu's commit fb93134dfc2a6e6fbedc7c270a31da03fce88db9, entitled
> "[TCP]: Fix size calculation in sk_stream_alloc_pskb", has triggered a
> bug in the 5701 where the 5701 DMA engine will corrupt outgoing
> packets.  This problem only happens when the starting address of the
> packet matches a certain range of offsets and only when the 5701 is
> placed downstream of a particular Intel bridge.
> 
> This patch detects the problematic bridge and if present, readjusts the
> starting address of the packet data to a dword aligned boundary.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks everyone.
