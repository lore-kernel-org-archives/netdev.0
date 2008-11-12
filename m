From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 03/13] user space API for time stamping of incoming
 and outgoing packets
Date: Wed, 12 Nov 2008 02:02:47 -0800 (PST)
Message-ID: <20081112.020247.26750755.davem@davemloft.net>
References: <1226414697.17450.852.camel@ecld0pohly>
	<1226415412.31699.2.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com,
	shemminger@vyatta.com, netdev@axxeo.de, ak@linux.intel.com,
	john.ronciak@intel.com, dada1@cosmosbay.com, oliver@hartkopp.net
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36726
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751420AbYKLKCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 05:02:48 -0500
In-Reply-To: <1226415412.31699.2.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Wed, 22 Oct 2008 17:01:05 +0200

> diff --git a/include/net/timestamping.h b/include/net/timestamping.h
> new file mode 100644
> index 0000000..53cb603
> --- /dev/null
> +++ b/include/net/timestamping.h
> @@ -0,0 +1,92 @@
> +#ifndef _NET_TIMESTAMPING_H
> +#define _NET_TIMESTAMPING_H
> +
> +#include <linux/socket.h>   /* for SO_TIMESTAMPING */
> +
> +/**
> + * user space linux/socket.h might not have these defines yet:
> + * provide fallback
> + */
> +#if !defined(__kernel__) && !defined(SO_TIMESTAMPING)

It's __KERNEL__ not __kernel__, and user visible interfaces
should not be added to <net/foo.h> files.

Rather, they should be put into <linux/foo.h> files.

Since "timestamping.h" is too generic a name, use something
like <linux/net_tstamp.h>
