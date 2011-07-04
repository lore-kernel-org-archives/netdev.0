From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: Make urgent data inline by default
Date: Mon, 04 Jul 2011 16:38:38 -0700 (PDT)
Message-ID: <20110704.163838.1746904172195321123.davem@davemloft.net>
References: <op.vx3hzgtw6ywr33@esapekka-pc.rad1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: esa-pekka.pyokkimies@stonesoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560Ab1GDXjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 19:39:02 -0400
In-Reply-To: <op.vx3hzgtw6ywr33@esapekka-pc.rad1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com>
Date: Mon, 4 Jul 2011 15:51:06 +0300

> Make urgent data inline by default. As explained in RFC 6093, urgent
> data should never be handled out-of-band.
> 
> "The TCP urgent mechanism is NOT a mechanism for sending "out-of-band"
>  data: the so-called "urgent data" should be delivered "in-line" to
>  the TCP user."
> 
> Signed-off-by: Esa-Pekka Pyokkimies
> <esa-pekka.pyokkimies@stonesoft.com>

There is no way we can make this change, we've had the default
we currently have for 18+ years.  Breaking applications is a
very real possibility.

It doesn't matter what some RFC says.

