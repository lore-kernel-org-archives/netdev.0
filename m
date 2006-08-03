From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 14:48:45 -0700 (PDT)
Message-ID: <20060803.144845.66061203.davem@davemloft.net>
References: <E1G8a0J-0002Pn-00@gondolin.me.apana.org.au>
	<1154630207.3117.17.camel@rh4>
	<20060803201741.GA7894@thunk.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62695
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030199AbWHCVt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 17:49:28 -0400
To: tytso@mit.edu
In-Reply-To: <20060803201741.GA7894@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Theodore Tso <tytso@mit.edu>
Date: Thu, 3 Aug 2006 16:17:41 -0400

> eth0: Tigon3 [partno(BCM95704s) rev 2100 PHY(serdes)] (PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:14:5e:86:44:24

The 5704 chip will set TG3_FLAG_TAGGED_STATUS, and therefore
doesn't need the periodic poking done by tg3_timer().
