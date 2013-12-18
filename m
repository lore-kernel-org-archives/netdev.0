From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/3] packet: deliver VLAN TPID to userspace
Date: Wed, 18 Dec 2013 00:37:13 -0500 (EST)
Message-ID: <20131218.003713.1615620624614481877.davem@davemloft.net>
References: <87haa77fe3.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	bhutchings@solarflare.com, dborkman@redhat.com,
	David.Laight@ACULAB.COM
To: atzm@stratosphere.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3LRFhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:37:15 -0500
In-Reply-To: <87haa77fe3.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atzm Watanabe <atzm@stratosphere.co.jp>
Date: Tue, 17 Dec 2013 22:53:24 +0900

> This patchset enables userspace to get VLAN TPID as well as the VLAN TCI.
> 
> After the 802.1AD support, userspace packet receivers (packet dumper,
> software switch, and the like) need how to know VLAN TPID in order to
> reconstruct original tagged frame.
> 
> v4: Simply use sizeof(tp_padding) for zeroing the padding bytes,
>     commented by David Laight.
>     Use __u16 for tp_vlan_tpid in tpacket_hdr_variant1,
>     commented by Daniel Borkmann.
> 
> v3: Add a definition which indicates whether tp_vlan_tpid is valid.
>     Explicitly define pad bytes for tpacket{2,3}_hdr and pick the area
>     for tp_vlan_tpid from the definition.  Commented by David Laight.
> 
> v2: Add BUILD_BUG_ON() to make current aligned size of
>     struct tpacket{2,3}_hdr clear.  Commented by Ben Hutchings.

Series applied, thank you.
