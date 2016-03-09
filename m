From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] macsec: introduce IEEE 802.1AE driver
Date: Wed, 09 Mar 2016 12:09:37 -0500 (EST)
Message-ID: <20160309.120937.544019796470786375.davem@davemloft.net>
References: <1457468033.24270.38.camel@sipsolutions.net>
	<20160309105614.GA24911@bistromath.redhat.com>
	<1457522660.2042.9.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, netdev@vger.kernel.org,
	hannes@stressinduktion.org, fw@strlen.de, pabeni@redhat.com,
	stephen@networkplumber.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933174AbcCIRJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:09:42 -0500
In-Reply-To: <1457522660.2042.9.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 09 Mar 2016 12:24:20 +0100

> Yeah, there's probably no way a compiler could ever do something with
> it that's not the same as packed, but it seems to me that just out of
> convention structs that have some wire-format meaning should usually be
> __packed.

Not unless absolutely necessary.

There is a serious performance penalty for using __packed on some
architectures.  __packed has several undesirable side-effects, one
of which is that it causes the compiler to be unable to assume the
alignment of anything.
