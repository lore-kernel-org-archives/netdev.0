From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Do not enable tx-nocache-copy by default
Date: Tue, 07 Jan 2014 16:20:53 -0500 (EST)
Message-ID: <20140107.162053.1127386147694253061.davem@davemloft.net>
References: <20140106.200002.1747627391067832069.davem@davemloft.net>
	<1389107470-18213-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, therbert@google.com
To: bpoirier@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbaAGVUz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:20:55 -0500
In-Reply-To: <1389107470-18213-1-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Benjamin Poirier <bpoirier@suse.de>
Date: Tue,  7 Jan 2014 10:11:10 -0500

> There are many cases where this feature does not improve performance =
or even
> reduces it.
>=20
> For example, here are the results from tests that I've run using 3.12=
=2E6 on one
> Intel Xeon W3565 and one i7 920 connected by ixgbe adapters. The resu=
lts are
> from the Xeon, but they're similar on the i7. All numbers report the
> mean=B1stddev over 10 runs of 10s.
>=20
> 1) latency tests similar to what is described in "c6e1a0d net: Allow =
no-cache
> copy from user on transmit"
> There is no statistically significant difference between tx-nocache-c=
opy
> on/off.
> nic irqs spread out (one queue per cpu)
 ...
> CC: Tom Herbert <therbert@google.com>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

Looks good, applied, thanks.
