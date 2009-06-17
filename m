From: David Miller <davem@davemloft.net>
Subject: Re: net: fix network drivers ndo_start_xmit() return values
Date: Wed, 17 Jun 2009 04:33:00 -0700 (PDT)
Message-ID: <20090617.043300.113013803.davem@davemloft.net>
References: <20090616071204.GB4494@ff.dom.local>
	<20090616.022241.47960267.davem@davemloft.net>
	<4A3766E4.3080500@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, perex@perex.cz
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47137
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933056AbZFQLc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 07:32:56 -0400
In-Reply-To: <4A3766E4.3080500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 16 Jun 2009 11:33:24 +0200

>     net: fix network drivers ndo_start_xmit() return values
>     
>     Fix up remaining drivers returning a magic or an errno value from their
>     ndo_start_xmit() functions that were missed in the first pass:
>     
>     - isdn_net: missed conversion
>     - bpqether: missed conversion: skb is freed, so return NETDEV_TX_OK
>     - hp100: intention appears to be to resubmit skb once resources are
>       available, but due to no queue handling it is dropped for now.
>     - lapbether: skb is freed, so return NETDEV_TX_OK
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
