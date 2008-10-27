From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
 addresses
Date: Mon, 27 Oct 2008 16:55:56 -0700 (PDT)
Message-ID: <20081027.165556.30975206.davem@davemloft.net>
References: <1225137542.5396.10.camel@brick>
	<20081027.154736.178482850.davem@davemloft.net>
	<1225149254.6339.4.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, anders@anduras.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49632
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751303AbYJ0X4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 19:56:19 -0400
In-Reply-To: <1225149254.6339.4.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Mon, 27 Oct 2008 16:14:14 -0700

> Did you happen to have a preference with regard to the specifier for
> IPv6 addresses:
> 
> I was thinking of using %pI6 to replace NIP6() and NIP6_FMT and using
> %#pI6 for NIP6_SEQFMT.
> 
> On the IPv4 side, maybe use %pI4 for network endian NIPQUAD() and NIPQUAD_FMT
> and then %#pI4 for host-endian HIQUAD(), as displaying the IPv4 address without
> the periods isn't useful?
> 
> What do you think of that?

I'm ok with the '#' modifier but remind me again what's wrong with
using plain %p4 and %p6?
