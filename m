From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 21:24:34 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1004202124140.30633@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1004202108240.27476@hs20-bc2-1.build.redhat.com>
 <20100420.181434.35828504.davem@davemloft.net>
 <Pine.LNX.4.64.1004202116570.29631@hs20-bc2-1.build.redhat.com>
 <20100420.182215.179278537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754250Ab0DUBYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 21:24:38 -0400
In-Reply-To: <20100420.182215.179278537.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > On Tue, 20 Apr 2010, David Miller wrote:
> > 
> >> From: Mikulas Patocka <mpatocka@redhat.com>
> >> Date: Tue, 20 Apr 2010 21:10:04 -0400 (EDT)
> >> 
> >> > I see, but GRO is turned off on my interfaces, according to ethtool.
> >> 
> >> GRO is just a flag bit, so it's possible that if your kernel is too
> >> old ethtool will always show that it's off.
> >> 
> >> If you haven't turned off GRO explicitly, then it's a good bet that
> >> this is why it looks like it's off.  And GRO is on by default.
> > 
> > I have kernel 2.6.34-rc4, ethtool 2.6.33 and GRO is off. I haven't turned 
> > it off, I left it on default.
> 
> See my follow-up, what ethtool output makes you think GRO is
> off?  "large-receive-offload" is not GRO

generic-receive-offload: off

Mikulas
