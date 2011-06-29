From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9 v3] myri10ge: rework parity error check and cleanup
Date: Wed, 29 Jun 2011 06:02:49 -0700 (PDT)
Message-ID: <20110629.060249.875705878453651687.davem@davemloft.net>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
	<1309187108-12715-3-git-send-email-mason@myri.com>
	<20110628035727.GA23979@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com
To: mason@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565Ab1F2NCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 09:02:53 -0400
In-Reply-To: <20110628035727.GA23979@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <mason@myri.com>
Date: Mon, 27 Jun 2011 22:57:28 -0500

> Clean up watchdog reset code:
>  - move code that checks for stuck slice to a common routine
>  - unless there is a confirmed h/w fault, verify that a stuck
>    slice is still stuck in the watchdog worker; if the slice is no
>    longer stuck, abort the reset.
>  - this removes an egregious 2000ms pause in the watchdog worker that
>    was a diagnostic aid (to look for spurious resets) the snuck into
>    production code.
> 
> v3 includes corrections from Joe Perches
> 
> Signed-off-by: Jon Mason <mason@myri.com>

Applied.
