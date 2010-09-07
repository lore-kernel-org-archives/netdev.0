From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] tipc: Minor optimizations to name table
 translation code
Date: Mon, 06 Sep 2010 18:13:14 -0700 (PDT)
Message-ID: <20100906.181314.232759243.davem@davemloft.net>
References: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754165Ab0IGBM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:12:57 -0400
In-Reply-To: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri,  3 Sep 2010 14:33:39 -0400

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> Optimizes TIPC's name table translation code to avoid unnecessary
> manipulation of the node address field of the resulting port id when
> name translation fails.  This change is possible because a valid port
> id cannot have a reference field of zero, so examining the reference
> only is sufficient to determine if the translation was successful.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
