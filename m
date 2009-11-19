From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: tasklet_init - Remove unnecessary leading
 & from second arg
Date: Thu, 19 Nov 2009 12:29:52 -0800 (PST)
Message-ID: <20091119.122952.66871908.davem@davemloft.net>
References: <1258659010.3863.11.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35973
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754841AbZKSU3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 15:29:35 -0500
In-Reply-To: <1258659010.3863.11.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 19 Nov 2009 11:30:10 -0800

> Changed function pointer use from non-majority address-of style
> to majority short form without & via: (was: 8 with &, 36 without)
> 
> grep -rPl "\btasklet_init\s*\([^,\)]+,\s*\&" drivers/net | while read file ; do \
> 	perl -i -e 'local $/; while (<>) { s@(\btasklet_init\s*\([^,\)]+,\s*)\&@\1@g ; print ; }' $file ;\
> done
> 
> Compile tested allyesconfig x86
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
