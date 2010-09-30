From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next-2.6 4/5] XFRM,IPv6: Add IRO remapping hook
 in xfrm_input()
Date: Wed, 29 Sep 2010 20:17:47 -0700 (PDT)
Message-ID: <20100929.201747.52185442.davem@davemloft.net>
References: <cover.1285749610.git.arno@natisbad.org>
	<cc9aa9a5b238d27701140d0d9230593954e53a39.1285749610.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34426
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752725Ab0I3DR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 23:17:26 -0400
In-Reply-To: <cc9aa9a5b238d27701140d0d9230593954e53a39.1285749610.git.arno@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaud Ebalard <arno@natisbad.org>
Date: Wed, 29 Sep 2010 11:05:59 +0200

> +EXPORT_SYMBOL(xfrm4_input_addr_check);

> +EXPORT_SYMBOL(xfrm6_input_addr_check);

net/ipv{4,6}/xfrm{4,6}_{state,input}.c will be built together as a
group, so there is no need to export the address check symbol to
modules.
