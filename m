From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: l3mdev: address selection should only consider
 devices in L3 domain
Date: Tue, 16 Feb 2016 20:05:18 -0500 (EST)
Message-ID: <20160216.200518.1495764396935534189.davem@davemloft.net>
References: <1455663591-27615-1-git-send-email-dsa@cumulusnetworks.com>
	<20160216234115.GI659150@eidolon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
	david@opensourcerouting.org
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933415AbcBQBFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 20:05:21 -0500
In-Reply-To: <20160216234115.GI659150@eidolon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Wed, 17 Feb 2016 00:41:15 +0100

> ... this won't do enough.  If you look at the 4.3 patch I sent you, I
> was adding a comment:
> 
> + /* For VRFs, the VRF device takes the place of the loopback device,
> +    with addresses on it being preferred.  Note in such cases the
> +    loopback device will be among the devices that fail the vrf_ifi
> +    equality check in the loop below.
> +  */

I know that some parts of of net/ipv4/devinet.c uses this comment
style, it is not correct for new networking code.  Therefore,
please update your patch to use the proper style:

	/* Like
	 * this.
	 */

Thanks.
