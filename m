From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib: Fix fib zone and its hash leak on namespace stop
Date: Thu, 28 Oct 2010 10:28:55 -0700 (PDT)
Message-ID: <20101028.102855.260094057.davem@davemloft.net>
References: <4CC965EB.60600@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46432
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934083Ab0J1R2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:28:32 -0400
In-Reply-To: <4CC965EB.60600@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 28 Oct 2010 16:00:43 +0400

> When we stop a namespace we flush the table and free one, but the
> added fn_zone-s (and their hashes if grown) are leaked. Need to free.
> Tries releases all its stuff in the flushing code.
> 
> Shame on us - this bug exists since the very first make-fib-per-net
> patches in 2.6.27 :(
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
