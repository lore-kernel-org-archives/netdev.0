From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
 addresses
Date: Mon, 27 Oct 2008 16:48:25 -0700
Message-ID: <1225151305.5269.105.camel@localhost>
References: <1225124904.5440.1.camel@brick>
	 <20081027.123805.134354592.davem@davemloft.net>
	 <1225137542.5396.10.camel@brick>
	 <20081027.154736.178482850.davem@davemloft.net>
	 <1225149254.6339.4.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	anders@anduras.de, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1623 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbYJ0XtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 19:49:10 -0400
In-Reply-To: <1225149254.6339.4.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-27 at 16:14 -0700, Harvey Harrison wrote:
> I was thinking of using %pI6 to replace NIP6() and NIP6_FMT and using
> %#pI6 for NIP6_SEQFMT.
> 
> On the IPv4 side, maybe use %pI4 for network endian NIPQUAD() and NIPQUAD_FMT
> and then %#pI4 for host-endian HIQUAD(), as displaying the IPv4 address without
> the periods isn't useful?

HIPQUAD is horrible and should disappear.
Just use htonl first.

I think just %p4 %p6 %#p6 for the NIP6_SEQFMT uses.

