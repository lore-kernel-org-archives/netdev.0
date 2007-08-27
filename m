From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Mon, 27 Aug 2007 14:37:24 -0700 (PDT)
Message-ID: <20070827.143724.38316150.davem@davemloft.net>
References: <1188212049.6756.18.camel@johannes.berg>
	<20070827.134131.41639376.davem@davemloft.net>
	<1188250006.18004.144.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55734
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763846AbXH0Vhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 17:37:47 -0400
In-Reply-To: <1188250006.18004.144.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 27 Aug 2007 14:26:46 -0700

> My original patch had the equivalent of
> 
> 	char* print_mac(char* buf, const char* addr) {
> 		sprintf(buf,"%02x:...", addr[0]...)
> 		return buf;
> 	}
> 
> and used:
> 
> 	DECLARE_MAC_BUF(var); //same as char var[18];
> 	printk(MAC_FMT, MAC_ARG(var, addr));
> 
> which didn't require splitting printk()s
> 
> I've still got the original patch.
> It's just substituting EUI48 for MAC and forward porting.
> 
> Want something like that?

That sounds OK.  Let's give Johannes a chance to give some
feedback first.
