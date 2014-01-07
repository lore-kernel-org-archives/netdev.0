From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Pack struct xfrm_usersa_info and struct
 xfrm_userpolicy_info
Date: Tue, 07 Jan 2014 13:07:49 -0500 (EST)
Message-ID: <20140107.130749.215535043457683103.davem@davemloft.net>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, stephen@networkplumber.org,
	dev@lists.strongswan.org, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbaAGSHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 13:07:53 -0500
In-Reply-To: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Tue, 7 Jan 2014 14:48:57 +0800

> When trying to setup IPsec configuration on a 64bits host with
> iproute2(32bits compiled), the intened xfrm policy and sa is
> either deficit or wrong when kernel trying to parse user land
> information.

You can't make this change without breaking userspace.

We'll have to translate the data structures somehow with a compat
layer like we have for 32/64 bit compatability for system calls.
