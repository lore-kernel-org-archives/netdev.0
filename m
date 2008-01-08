From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.23-rc8 network problem. Mem leak? ip1000a?
Date: Mon, 07 Jan 2008 23:07:09 -0800 (PST)
Message-ID: <20080107.230709.216880096.davem@davemloft.net>
References: <20070930022347.37514be3.akpm@linux-foundation.org>
	<20080108065211.25290.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754478AbYAHHHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 02:07:09 -0500
In-Reply-To: <20080108065211.25290.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: linux@horizon.com
Date: 8 Jan 2008 01:52:11 -0500

> @@ -172,6 +172,10 @@ config IP1000
>  	select MII
>  	---help---
>  	  This driver supports IP1000 gigabit Ethernet cards.
> +	  It works, but suffers from a memory leak.  Signifcant
> +	  use will consume unswappable kernel memory until the
> +	  machine runs out of memory and crashes.  Thus, this
> +	  driver cannot be considered usable at the the present time.

This is not how we handle and track bugs.

Such a patch is inappropriate, and I'd like to ask that you just be
patient until someone has a chance to try and figure out what the
problem is.  Or even better, you can try to track down the problem
yourself since you seem to have a specific interest in this problem.

Thanks.
