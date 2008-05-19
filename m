From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/6][IP6FRAGS]: Handle error, returned from
 register_pernet_subsys.
Date: Mon, 19 May 2008 13:54:10 -0700 (PDT)
Message-ID: <20080519.135410.24824916.davem@davemloft.net>
References: <4831A1D6.4090503@openvz.org>
	<4831A491.2020009@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56348
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757881AbYESUyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 16:54:15 -0400
In-Reply-To: <4831A491.2020009@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 19 May 2008 20:02:25 +0400

> The error code is ignored now, but ipv6 is a module and one can
> be loaded under memory pressure, so the error may occur (in theory).
> 
> Besides, I'm going to handle error returned from registering a
> read-only part of the table, so ignoring this one, while handing
> the other one would look strange.
> 
> (However, this possibility of error is rather small, so I'm not 
>  sure whether this is a candidate for current net tree).

I definitely don't consider it -stable material.

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks!
