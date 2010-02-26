From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RFC] [1/13] bridge: Add IGMP snooping support
Date: Fri, 26 Feb 2010 23:34:10 +0800
Message-ID: <20100226153410.GA26419@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52498 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965046Ab0BZPeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 10:34:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This series of patches adds basic IGMP support to the bridge
device.  First of all the following is not currently supported
but may be added in future:

* IGMPv3 source support (so really just IGMPv2 for now)
* Non-querier router detection
* IPv6

The series is divided into two portions:

1-5 lays the ground work and can be merged without any of the
other patches.

6-13 are the actual IGMP-specific patches.

This is a kernel-only implementation.  In future we could move
parts of this into user-space just like RTP.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
