From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: request_irq - Remove unnecessary
 leading & from second arg
Date: Wed, 18 Nov 2009 23:29:27 -0800 (PST)
Message-ID: <20091118.232927.133649487.davem@davemloft.net>
References: <Pine.LNX.4.64.0911181925440.20943@ask.diku.dk>
	<20091118.105237.127029548.davem@davemloft.net>
	<1258587958.24178.222.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, julia@diku.dk, ebiederm@xmission.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32768
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752074AbZKSH3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 02:29:10 -0500
In-Reply-To: <1258587958.24178.222.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 18 Nov 2009 15:45:57 -0800

> Not as fancy as coccinelle.  Checkpatch errors ignored.
> Compile tested allyesconfig x86, not all files compiled.
> 
> grep -rPl --include=*.[ch] "\brequest_irq\s*\([^,\)]+,\s*\&" drivers/net | while read file ; do \
> 	perl -i -e 'local $/; while (<>) { s@(\brequest_irq\s*\([^,\)]+,\s*)\&@\1@g ; print ; }' $file ;\
> done
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
