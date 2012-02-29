From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mdio: Export mdio.h to userland
Date: Wed, 29 Feb 2012 15:42:27 -0500 (EST)
Message-ID: <20120229.154227.908693909825012701.davem@davemloft.net>
References: <1330542122.5881.2.camel@bwh-desktop>
	<1330542754.5881.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33567 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755638Ab2B2Um3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 15:42:29 -0500
In-Reply-To: <1330542754.5881.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 29 Feb 2012 19:12:34 +0000

> On Wed, 2012-02-29 at 19:02 +0000, Ben Hutchings wrote:
>> The ID packing/unpacking functions are needed by userland and the
>> register definitions may also be useful there.
> 
> Minor issue with this: mdio_phy_id_is_c45() returns bool, and that's not
> defined by default.  Should I add #include <stdbool.h> or change the
> return type to int for maximum compatibility?

I do not see any precedence for including stdbool.h in a kernel header
file.  And I sure as hell am not going to compromise using a correct
type just to make this usable by userspace.

I think this is of dubious value, and combined with the bool
complication I'm not going to apply this, sorry.
