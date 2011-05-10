From: Rafael Aquini <aquini@linux.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Tue, 10 May 2011 09:22:31 -0300
Message-ID: <20110510122228.GA3011@x61.tchesoft.com>
References: <20110510000758.GA12728@x61.tchesoft.com>
 <23511.1304992840@death>
Reply-To: aquini@linux.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, Nicolas Kaiser <nikai@nikai.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:36935 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085Ab1EJM0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 08:26:12 -0400
Content-Disposition: inline
In-Reply-To: <23511.1304992840@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy Jay,

On Mon, May 09, 2011 at 07:00:40PM -0700, Jay Vosburgh wrote:
> >@@ -644,9 +640,7 @@ static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
> >  */
> > static void __attach_bond_to_agg(struct port *port)
> > {
> >-	port = NULL; /* just to satisfy the compiler */
> >-	// This function does nothing since the parser/multiplexer of the receive
> >-	// and the parser/multiplexer of the aggregator are already combined
> >+	port = NULL;
> > }
> >
> > /**
> >@@ -659,9 +653,7 @@ static void __attach_bond_to_agg(struct port *port)
> >  */
> > static void __detach_bond_from_agg(struct port *port)
> > {
> >-	port = NULL; /* just to satisfy the compiler */
> >-	// This function does nothing sience the parser/multiplexer of the receive
> >-	// and the parser/multiplexer of the aggregator are already combined
> >+	port = NULL;
> 
> 	These two do-nothing functions should either
> 
> 	a) be removed entirely, and their call site replaced with a
> comment explaining this variation on the standard (that we don't need
> the "Attach_Mux_To_Aggregator" or "Detach_Mux_From_Aggregator" functions
> specified in the standard for the "Mux machine state diagram"), or
> 
> 	b) the comment needs to remain in some form to document this
> variation on the standard.
> 
Those comments were stripped from the function bodies because they already are
present in their leading comment blocks. Leaving them there sounded to me just
like echoing the very same thing twice.

However, each one of those functions is just called once from ad_mux_machine(),
so it might be a better idea (and easy) to wipe them away -- following your
suggestion a); or we can just leave them there, turning them into inline
functions instead. What approach do you prefer?

All other notes and suggestions you provide me will be accomplished soon.

Thanks for keep providing valuable feedback.

Cheers!
-- 
Rafael Aquini <aquini@linux.com>
