From: David Miller <davem@davemloft.net>
Subject: Re: [KJ] [patch] net/tipc: sprintf/strcpy conversion
Date: Wed, 01 Nov 2006 15:19:17 -0800 (PST)
Message-ID: <20061101.151917.133285028.davem@davemloft.net>
References: <20061101140624.GA7694@Chamillionaire.breakpoint.cc>
	<454913D2.9050608@bfs.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@lists.osdl.org,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18857
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751004AbWKAXTM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 18:19:12 -0500
To: wharms@bfs.de
In-Reply-To: <454913D2.9050608@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: walter harms <wharms@bfs.de>
Date: Wed, 01 Nov 2006 22:38:26 +0100

> These line
> +	strcpy(bcbearer->media.name, "tipc-multicast");
> 
> i gues that means tipc_bclink_name ?

Why?  The original code used "tipc-multicast" which is a
different string than tipc_bclink_name which is "multicast-link".

> > -	sprintf(bcbearer->media.name, "tipc-multicast");
> > +	strcpy(bcbearer->media.name, "tipc-multicast");

If you are arguing that it should be changed, that's a different
changeset to discuss.
