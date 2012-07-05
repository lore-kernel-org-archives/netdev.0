From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4: defer fib_compute_spec_dst() call
Date: Thu, 05 Jul 2012 03:03:58 -0700 (PDT)
Message-ID: <20120705.030358.1169757448115476785.davem@davemloft.net>
References: <1341477009.2583.3406.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55038 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab2GEKD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 06:03:59 -0400
In-Reply-To: <1341477009.2583.3406.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Jul 2012 10:30:09 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> ip_options_compile() can avoid calling fib_compute_spec_dst()
> by default, and perform the call only if needed.
> 
> David suggested to add a helper to make the call only once.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks a lot Eric.
