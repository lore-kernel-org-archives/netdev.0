From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] printk: add %p6 format specifier for IPv6 addresses
Date: Tue, 28 Oct 2008 16:05:01 -0700 (PDT)
Message-ID: <20081028.160501.153997657.davem@davemloft.net>
References: <1225223612.11483.34.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54310
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753243AbYJ1XFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:05:24 -0400
In-Reply-To: <1225223612.11483.34.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Tue, 28 Oct 2008 12:53:32 -0700

> Takes a pointer to a IPv6 address and formats it in the usual
> colon-separated hex format:
> xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx
> 
> Each 16 bit word is printed in network-endian byteorder.
> 
> %#p6 is also supported and will omit the colons.
> 
> %p6 is a replacement for NIP6_FMT and NIP6()
> %#p6 is a replacement for NIP6_SEQFMT and NIP6()
> 
> Note that NIP6() took a struct in6_addr whereas this takes a pointer
> to a struct in6_addr.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks Harvey.
