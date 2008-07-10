From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] netlabel: netlink_unicast calls kfree_skb on error
 path by itself
Date: Thu, 10 Jul 2008 16:53:49 -0700 (PDT)
Message-ID: <20080710.165349.82186557.davem@davemloft.net>
References: <1215695484-17519-1-git-send-email-den@openvz.org>
	<200807100942.49545.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754787AbYGJXxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 19:53:49 -0400
In-Reply-To: <200807100942.49545.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Thu, 10 Jul 2008 09:42:49 -0400

> On Thursday 10 July 2008 9:11:24 am Denis V. Lunev wrote:
> > So, no need to kfree_skb here on the error path. In this case we can
> > simply return.
> >
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> Hi Denis,
> 
> Thanks for catching this and fixing it.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

Applied, thanks guys!
