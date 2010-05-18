From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Remove unnecessary returns from void
 function()s
Date: Mon, 17 May 2010 23:08:32 -0700 (PDT)
Message-ID: <20100517.230832.133881440.davem@davemloft.net>
References: <1273599941.20514.235.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755314Ab0ERGIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 02:08:23 -0400
In-Reply-To: <1273599941.20514.235.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 11 May 2010 10:45:41 -0700

> This patch removes from net/ (but not any netfilter files)
> all the unnecessary return; statements that precede the
> last closing brace of void functions.
> 
> It does not remove the returns that are immediately
> preceded by a label as gcc doesn't like that.
> 
> Done via:
> $ grep -rP --include=*.[ch] -l "return;\n}" net/ | \
>   xargs perl -i -e 'local $/ ; while (<>) { s/\n[ \t\n]+return;\n}/\n}/g; print; }'
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
