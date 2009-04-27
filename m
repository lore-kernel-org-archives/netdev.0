From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: ignore updelay param when there is no active
 slave
Date: Mon, 27 Apr 2009 02:58:03 -0700 (PDT)
Message-ID: <20090427.025803.183811676.davem@davemloft.net>
References: <20090424135728.GA12304@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46679
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757898AbZD0J6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:58:10 -0400
In-Reply-To: <20090424135728.GA12304@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 24 Apr 2009 15:57:29 +0200

> Pointed out by Sean E. Millichamp.
> 
> Quote from Documentation/networking/bonding.txt:
> "Note that when a bonding interface has no active links, the
> driver will immediately reuse the first link that goes up, even if the
> updelay parameter has been specified (the updelay is ignored in this
> case).  If there are slave interfaces waiting for the updelay timeout
> to expire, the interface that first went into that state will be
> immediately reused.  This reduces down time of the network if the
> value of updelay has been overestimated, and since this occurs only in
> cases with no connectivity, there is no additional penalty for
> ignoring the updelay."
> 
> This patch actually changes the behaviour in this way.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied to net-next-2.6
