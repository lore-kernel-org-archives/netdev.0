From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/20] Delete more semi-useless stuff from
 TIPC.
Date: Sat, 01 Jan 2011 13:59:52 -0800 (PST)
Message-ID: <20110101.135952.226766850.davem@davemloft.net>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60987
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752691Ab1AAV7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 16:59:22 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 31 Dec 2010 23:59:15 -0500

> There really isn't a lot to see here technically.  There is a bunch of
> stuff in TIPC that I guess falls into the category of "seemed like a
> good idea at the time", but is now just inactive or at best unstable
> prototype code for things like slave nodes and routing features and
> mulitcluster support.  My favourite is this one:
> 
>  ----------
> config TIPC_CLUSTERS
>        int "Maximum number of clusters in a zone"
>        depends on TIPC_ADVANCED
>        range 1 1
>        default "1"
>        help
>          Specifies how many clusters can be supported in a TIPC zone.
> 
>          *** Currently TIPC only supports a single cluster per zone. ***
>  ----------
> 
> The remaining commits are just de-uglifying what is left, fixing whitespace
> crimes and other common errors typically picked up in janitor patches.

All applied, thanks Paul.

net/tipc/log.h still uses "_TIPC_DBG_H" for it's multiple-include protection
tests.  Please send me a patch to rename that to _TIPC_LOG_H

Thanks.
