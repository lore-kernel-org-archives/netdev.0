From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH][NET] Convert init_timer into setup_timer
Date: Tue, 13 Nov 2007 11:43:40 -0200
Message-ID: <20071113134340.GI3943@ghostprotocols.net>
References: <4739A22B.20600@openvz.org> <20071113.053421.68786227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752973AbXKMNnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 08:43:46 -0500
Content-Disposition: inline
In-Reply-To: <20071113.053421.68786227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Nov 13, 2007 at 05:34:21AM -0800, David Miller escreveu:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Tue, 13 Nov 2007 16:10:03 +0300
> 
> > Many-many code in the kernel initialized the timer->function 
> > and  timer->data together with calling init_timer(timer). There 
> > is already a helper for this. Use it for networking code.
> > 
> > The patch is HUGE, but makes the code 130 lines shorter 
> > (98 insertions(+), 228 deletions(-)).
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> I have no objection to this patch, but it is 2.6.25
> material for sure.

Agreed, Pavel, if you want please stick:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo
