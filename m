From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: Add schedule check to napi_enable call
Date: Thu, 10 Feb 2011 11:03:46 -0800 (PST)
Message-ID: <20110210.110346.71098400.davem@davemloft.net>
References: <201102101232.50526.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kstailey@yahoo.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43856
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751162Ab1BJTDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 14:03:10 -0500
In-Reply-To: <201102101232.50526.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 10 Feb 2011 12:32:50 +1030

> From: "Bruce Rogers" <brogers@novell.com>
> 
> Under harsh testing conditions, including low memory, the guest would
> stop receiving packets. With this patch applied we no longer see any
> problems in the driver while performing these tests for extended periods
> of time.
> 
> Make sure napi is scheduled subsequent to each napi_enable.
> 
> Signed-off-by: Bruce Rogers <brogers@novell.com>
> Signed-off-by: Olaf Kirch <okir@suse.de>
> Cc: stable@kernel.org
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied, thanks everyone.
