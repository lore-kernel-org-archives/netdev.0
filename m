From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/isdn/gigaset: tasklet_init - Remove
 unnecessary leading & from second arg
Date: Thu, 19 Nov 2009 12:29:59 -0800 (PST)
Message-ID: <20091119.122959.235896961.davem@davemloft.net>
References: <1258660553.3863.18.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hjlipp@web.de, tilman@imap.cc,
	isdn@linux-pingi.de, gigaset307x-common@lists.sourceforge.net
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35977
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755783AbZKSU3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 15:29:42 -0500
In-Reply-To: <1258660553.3863.18.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 19 Nov 2009 11:55:53 -0800

> Changed function pointer use from non-majority address-of style
> to majority short form without & via:
> 
> grep -rPl "\btasklet_init\s*\([^,\)]+,\s*\&" drivers/isdn | while read file ; do \
>         perl -i -e 'local $/; while (<>) { s@(\btasklet_init\s*\([^,\)]+,\s*)\&@\1@g ; print ; }' $file ;\
> done
> 
> Compile tested allyesconfig x86
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
