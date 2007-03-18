From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [SK_BUFF]: Don't apply the offset of two
 allocations to the layer headers
Date: Sun, 18 Mar 2007 00:55:13 -0700 (PDT)
Message-ID: <20070318.005513.104034902.davem@davemloft.net>
References: <20070318031224.GA17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41485
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753121AbXCRHzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 03:55:13 -0400
In-Reply-To: <20070318031224.GA17811@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 18 Mar 2007 00:12:24 -0300

> 
> 	Here is the bugger, it wasn't because {transport,network,mac}_header
> is unsigned after all :-)
> 
> 	Please consider pulling from the usual place:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22

Pulled and pushed out, thanks a lot!

> 	Please lemme know how longer it takes to crash your workstation, I hope
> not before next century 8-)

I'll play with it after I figure out another bug I'm working
on first :)

