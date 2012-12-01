From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 3/3] net/mlx4_en: Set number of rx/tx
 channels using ethtool
Date: Sat, 01 Dec 2012 11:25:55 -0500 (EST)
Message-ID: <20121201.112555.1561917161372059709.davem@davemloft.net>
References: <1354216903-830-4-git-send-email-amirv@mellanox.com>
	<1354319925.2640.3.camel@bwh-desktop.uk.solarflarecom.com>
	<CAJZOPZK98UOsK2HFSC3V6fdzvJfWVKg6pZzxptE97MTgOAk7-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, amirv@mellanox.com,
	ogerlitz@mellanox.com, oren@mellanox.com, netdev@vger.kernel.org
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53592 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302Ab2LAQZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 11:25:57 -0500
In-Reply-To: <CAJZOPZK98UOsK2HFSC3V6fdzvJfWVKg6pZzxptE97MTgOAk7-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Sat, 1 Dec 2012 17:50:09 +0200

> On Sat, Dec 1, 2012 at 1:58 AM, Ben Hutchings <bhutchings@solarflare.com> wrote:
>>
>> The values of max_tx and max_rx are passed in from userland, so you
>> can't trust them.
> 
> Is this a general statement re ethtool values passed from user space
> or something specific here? can't one assume that the ethtool process
> runs under the appropriate admin permission?

He's saying that you need to carefully validate the arguments, not
that appropriate permissions haven't been checked.
