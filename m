From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/3] [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Mon, 13 Nov 2006 08:32:44 +0000
Message-ID: <200611130832.44409@strip-the-willow>
References: <200611130734.49700@strip-the-willow> <200611130809.34613@strip-the-willow> <20061113.001615.74565996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:8364 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1750701AbWKMIcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 03:32:53 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061113.001615.74565996.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|  > It is not a huge problem to change this, but it will also mean a non-trivial redesign.
|  > With regards to Stephen's email, can you/Stephen please indicate whether
|  > 
|  > 	(a) configurable or not (CONFIG_IP_UDPLITE)?
|  > 	(b) re-design as separate object file or not?
|  > 	(c) ... ?
|  
|  I don't think it needs to be configurable, and I also think the
|  split-out is easy as you just need to un-static a few things, and put
|  function declarations and perhaps a few inlines into a
|  net/ipv{4,6}/udp_impl.h header file that both udp.c and udplite.c both
|  include.
If you give me time until tomorrow morning, I will re-submit the split version - I would
like to take some time to go over it. I will use the filename as suggested for the header
file, unless there is another suggestion (the only header file in net/ipv?/ so far is 
fib_lookup.h).

Thanking you,
Gerrit
