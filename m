From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Force speed and duplex mode setting if link down
Date: Mon, 02 Jun 2014 16:48:41 -0700 (PDT)
Message-ID: <20140602.164841.1610935068756662568.davem@davemloft.net>
References: <1401750420-6668-1-git-send-email-stannous@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com
To: stannous@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbaFBXsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:48:42 -0400
In-Reply-To: <1401750420-6668-1-git-send-email-stannous@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: stannous@cumulusnetworks.com
Date: Mon,  2 Jun 2014 19:07:00 -0400

> +			/* If the interface is down, we'll get an ecmd speed and
> +			   duplex of 0.  This has the effect of defaulting
> +			   the duplex mode to HALF.  This results in an
> +			   error since many of our speeds will not support HALF
> +			   any more.  To prevent this, we need to insist that
> +			   the user provide us with specific duplex mode if
> +			   they haven't already (likely FULL) if both the speed
> +			   and duplex are 0 here.
> +			*/

This comment is not formatted properly for the neworking, the proper layout
is:

	/* Like
	 * this.
	 */

Also, your subject line needs to be adjusted.  After "[PATCH] " you must
specify a subsystem prefix, which here would be something like
"ethtool: ".  This way people reading the commit log headers can see where
in the kernel your changes are happening.
