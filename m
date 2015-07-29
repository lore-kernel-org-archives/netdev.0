From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] arp: filter NOARP neighbours for SIOCGARP
Date: Wed, 29 Jul 2015 11:32:23 +0200
Message-ID: <1438162343.20182.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1437989630.20182.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150728.234147.1087098759056655521.davem@davemloft.net>
	 <1438161351.20182.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, valas@google.com, willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35534 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbbG2Jc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 05:32:27 -0400
Received: by wibxm9 with SMTP id xm9so192342698wib.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 02:32:26 -0700 (PDT)
In-Reply-To: <1438161351.20182.73.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-29 at 11:15 +0200, Eric Dumazet wrote:
> On Tue, 2015-07-28 at 23:41 -0700, David Miller wrote:
> 
> > Applied, thanks Eric.
> Thanks David
> 
> Note that IPv6 is completely broken after 'arp off' sequence.

It seems we need to replicate what commit
6c8b4e3ff81b82fc153625e81e60af1d89de2c32 ("arp: flush arp cache on
IFF_NOARP change") 
did for IPv4

Will test this and submit an official patch.
