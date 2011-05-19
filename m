From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft
 RFC 2988bis-02.
Date: Thu, 19 May 2011 01:46:56 -0400 (EDT)
Message-ID: <20110519.014656.1735519603194773578.davem@davemloft.net>
References: <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
	<20110519.001426.2119532755281545481.davem@davemloft.net>
	<BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, hagen@jauu.net,
	eric.dumazet@gmail.com, alexander.zimmermann@comsys.rwth-aachen.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tsunanet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: tsuna <tsunanet@gmail.com>
Date: Wed, 18 May 2011 21:33:21 -0700

> On Wed, May 18, 2011 at 9:14 PM, David Miller <davem@davemloft.net> wrote:
>> I really would rather see the initial RTO be static and be set to 1
>> with fallback RTO of 3.
> 
> I can also provide a simple patch for this if you want to start from
> there.  And then maybe we can discuss having a runtime knob some more
> :-)

Yeah why don't we do that :-)
