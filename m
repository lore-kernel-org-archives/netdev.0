From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6/stable] [XFRM] AUDIT: Fix flowlabel text format.
Date: Sat, 26 Apr 2008 22:25:12 -0700 (PDT)
Message-ID: <20080426.222512.134613395.davem@davemloft.net>
References: <20080427.122418.32604330.yoshfuji@linux-ipv6.org>
	<20080426.202558.208247674.davem@davemloft.net>
	<20080427.125437.59237838.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42914
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751010AbYD0FZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 01:25:12 -0400
In-Reply-To: <20080427.125437.59237838.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sun, 27 Apr 2008 12:54:37 +0900 (JST)

> In article <20080426.202558.208247674.davem@davemloft.net> (at Sat, 26 Apr 2008 20:25:58 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > What about the format is it fixing?
> 
> Sorry...

I now understand the problem with the new changelog message.

> > Also, can this possibly break existing audit log scanning
> > tools and parsers?
> 
> James?
> 
> We could add "flowlabel", but it is possible to break something, too.
> Anyway, because the log format did not make sense as audit log,
> we need to fix it.
> 
> ---
> [XFRM] AUDIT: Fix flowlabel text format ambibuity.
> 
> Flowlabel text format was not correct and thus ambiguous.
> For example, 0x00123 or 0x01203 are formatted as 0x123.
> This is not what audit tools want.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied, James if you have some objections let me know,
otherwise I'll toss this to -stable too.

Thanks!
