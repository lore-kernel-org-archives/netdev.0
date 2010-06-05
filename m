From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2][v2] bonding: add all_slaves_active
 parameter
Date: Sat, 05 Jun 2010 02:54:40 -0700 (PDT)
Message-ID: <20100605.025440.233678822.davem@davemloft.net>
References: <20100602183921.GK7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, nhorman@tuxdriver.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46390
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932754Ab0FEJy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:54:29 -0400
In-Reply-To: <20100602183921.GK7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 2 Jun 2010 14:39:21 -0400

> 
> v2: changed parameter name from 'keep_all' to 'all_slaves_active' and
> skipped setting slaves to inactive rather than creating a new flag at
> Jay's suggestion.
> 
> In an effort to suppress duplicate frames on certain bonding modes
> (specifically the modes that do not require additional configuration on
> the switch or switches connected to the host), code was added in the
> generic receive patch in 2.6.16.  The current behavior works quite well
> for most users, but there are some times it would be nice to restore old
> functionality and allow all frames to make their way up the stack.
> 
> This patch adds support for a new module option and sysfs file called
> 'all_slaves_active' that will restore pre-2.6.16 functionality if the
> user desires.  The default value is '0' and retains existing behavior,
> but the user can set it to '1' and allow all frames up if desired.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
