From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
 addresses
Date: Mon, 27 Oct 2008 17:05:39 -0700
Message-ID: <1225152339.5526.1.camel@brick>
References: <1225137542.5396.10.camel@brick>
	 <20081027.154736.178482850.davem@davemloft.net>
	 <1225149254.6339.4.camel@brick>
	 <20081027.165556.30975206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, anders@anduras.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:21739 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470AbYJ1AFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 20:05:42 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2400108rvb.1
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 17:05:41 -0700 (PDT)
In-Reply-To: <20081027.165556.30975206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-27 at 16:55 -0700, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Mon, 27 Oct 2008 16:14:14 -0700
> 
> > Did you happen to have a preference with regard to the specifier for
> > IPv6 addresses:
> > 
> > I was thinking of using %pI6 to replace NIP6() and NIP6_FMT and using
> > %#pI6 for NIP6_SEQFMT.
> > 
> > On the IPv4 side, maybe use %pI4 for network endian NIPQUAD() and NIPQUAD_FMT
> > and then %#pI4 for host-endian HIQUAD(), as displaying the IPv4 address without
> > the periods isn't useful?
> > 
> > What do you think of that?
> 
> I'm ok with the '#' modifier but remind me again what's wrong with
> using plain %p4 and %p6?

Nothing at all, just wanted to know what color bikeshed you wanted.

I'll go with %p4 %p6.

Harvey

