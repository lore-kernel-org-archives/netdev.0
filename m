From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netxen: avoid frequent firmware reset
Date: Thu, 02 Jul 2009 13:17:41 -0700 (PDT)
Message-ID: <20090702.131741.10488154.davem@davemloft.net>
References: <1246484503-10817-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38072
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757300AbZGBURf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 16:17:35 -0400
In-Reply-To: <1246484503-10817-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Wed,  1 Jul 2009 14:41:43 -0700

> Restrict firmware reset to following cases -
> 
> o chip rev is NX2031 (firmare doesn't support heartbit).
> o firmware is dead.
> o previous attempt to init firmware had failed.
> o we have got newer file firmware.
> 
> This speeds up module load tremendously (by upto 8 sec),
> also avoids downtime for NCSI (management) pass-thru
> traffic.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
