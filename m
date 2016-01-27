From: David Miller <davem@davemloft.net>
Subject: Re: for stable: xfrm: dst_entries_init() per-net dst_ops
Date: Tue, 26 Jan 2016 17:50:55 -0800 (PST)
Message-ID: <20160126.175055.114274520618621016.davem@davemloft.net>
References: <CALZtONBA3hi_Gj5uAzTc6Wb-2Tk5NqVDPRkC=FLxj3G=_bdrzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	dan.streetman@canonical.com
To: ddstreet@ieee.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbcA0Bu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 20:50:57 -0500
In-Reply-To: <CALZtONBA3hi_Gj5uAzTc6Wb-2Tk5NqVDPRkC=FLxj3G=_bdrzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 25 Jan 2016 12:36:57 -0500

> David, can you queue commit a8a572a for stable please?  It fixes
> commit d7c7544c3d from 2010, and without it anyone using multiple
> ipsec net namespaces can find one (or more) of their netns incorrectly
> reach the ipsec dst limit and are no longer usable.

Done, thanks.
