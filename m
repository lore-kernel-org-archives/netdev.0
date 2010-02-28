From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/13] bridge: Add IGMP snooping support
Date: Sun, 28 Feb 2010 13:40:12 +0800
Message-ID: <20100228054012.GA7583@gondor.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54161 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751273Ab0B1FkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 00:40:15 -0500
Content-Disposition: inline
In-Reply-To: <20100226153410.GA26419@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This is a repost of exactly the same series in order to get them
back into patchworks.  I hope I have resolved your concerns about
patch number 2.  Let me know if you still have any further questions.

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
