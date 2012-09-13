From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: GRO aggregation
Date: Thu, 13 Sep 2012 12:59:30 +0300
Message-ID: <CAJZOPZL8qrqYfAvcQBDB9CFy7WwztWchaMyADGBnwKpW-r1Q4g@mail.gmail.com>
References: <504F4063.9030706@mellanox.com>
	<1347388396.13103.658.camel@edumazet-glaptop>
	<36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
	<1347390113.13103.660.camel@edumazet-glaptop>
	<36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
	<1347392132.13103.663.camel@edumazet-glaptop>
	<505054AE.9040901@mellanox.com>
	<1347442394.13103.703.camel@edumazet-glaptop>
	<50509F30.30402@mellanox.com>
	<5050B6FF.5050002@hp.com>
	<5050B9B2.5070107@mellanox.com>
	<5050BDB5.8090200@hp.com>
	<50517F01.9050501@mellanox.com>
	<1347523865.13103.1423.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Shlomo Pongartz <shlomop@mellanox.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52491 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab2IMJ7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 05:59:31 -0400
Received: by iahk25 with SMTP id k25so2041200iah.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 02:59:30 -0700 (PDT)
In-Reply-To: <1347523865.13103.1423.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 13, 2012 at 11:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> MAX_SKB_FRAGS is 16
> skb_gro_receive() will return -E2BIG once this limit is hit.
> If you use a MSS = 100 (instead of MSS = 1460), then GRO skb will
> contain only at most 1700 bytes, but TSO packets can still be 64KB, if
> the sender NIC can afford it (some NICS wont work quite well)

Hi Eric,

Addressing this assertion of yours, Shlomo showed that with ixgbe he managed
to see GRO aggregating 32KB which means 20-21 packets that is > 16 fragments
in this notation, can it be related to the way ixgbe is actually
allocating skbs?

Or.
