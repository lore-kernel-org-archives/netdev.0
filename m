From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET] Convert init_timer into setup_timer
Date: Tue, 13 Nov 2007 21:14:28 -0800 (PST)
Message-ID: <20071113.211428.229371832.davem@davemloft.net>
References: <4739A22B.20600@openvz.org>
	<20071113.053421.68786227.davem@davemloft.net>
	<20071113134340.GI3943@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751530AbXKNFO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:14:29 -0500
In-Reply-To: <20071113134340.GI3943@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Date: Tue, 13 Nov 2007 11:43:40 -0200

> Em Tue, Nov 13, 2007 at 05:34:21AM -0800, David Miller escreveu:
> > From: Pavel Emelyanov <xemul@openvz.org>
> > Date: Tue, 13 Nov 2007 16:10:03 +0300
> > 
> > > Many-many code in the kernel initialized the timer->function 
> > > and  timer->data together with calling init_timer(timer). There 
> > > is already a helper for this. Use it for networking code.
> > > 
> > > The patch is HUGE, but makes the code 130 lines shorter 
> > > (98 insertions(+), 228 deletions(-)).
> > > 
> > > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> > 
> > I have no objection to this patch, but it is 2.6.25
> > material for sure.
> 
> Agreed, Pavel, if you want please stick:
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

No need, I've applied it to net-2.6.25 :-)
