From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPIP: Allow rebinding the tunnel to another interface
Date: Wed, 12 Dec 2007 11:02:06 -0800 (PST)
Message-ID: <20071212.110206.266391918.davem@davemloft.net>
References: <20071212163451.498b5726@brian.englab.brq.redhat.com>
	<4760058E.5080403@trash.net>
	<20071212172933.178cf78e@brian.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, mmaslano@redhat.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753245AbXLLTCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 14:02:07 -0500
In-Reply-To: <20071212172933.178cf78e@brian.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Wed, 12 Dec 2007 17:29:33 +0100

> On Wed, 12 Dec 2007 17:00:14 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > If you change dev->iflink this should trigger a rtnetlink
> > notification.
> 
> OK, I've added netdev_state_change(dev). Here's the new patch.

Applied to net-2.6.25, thanks.
