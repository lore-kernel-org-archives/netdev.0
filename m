From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Mon, 13 Nov 2006 01:28:22 -0800 (PST)
Message-ID: <20061113.012822.48527926.davem@davemloft.net>
References: <200611130809.34613@strip-the-willow>
	<20061113.001615.74565996.davem@davemloft.net>
	<200611130832.44409@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44715
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751036AbWKMJ2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 04:28:16 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200611130832.44409@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 13 Nov 2006 08:32:44 +0000

> If you give me time until tomorrow morning, I will re-submit the
> split version - I would like to take some time to go over it. I will
> use the filename as suggested for the header file, unless there is
> another suggestion (the only header file in net/ipv?/ so far is
> fib_lookup.h).

It should be fine as a name, and if you look at fib_lookup.h
it's serving the same purpose the udp_impl.h file will, in
that it provides interfaces for internals of the fib_*.c
files.
