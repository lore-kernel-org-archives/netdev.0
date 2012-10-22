From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Sun, 21 Oct 2012 20:43:51 -0400 (EDT)
Message-ID: <20121021.204351.350463326482954461.davem@davemloft.net>
References: <508123AC.5080208@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746Ab2JVAnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 20:43:53 -0400
In-Reply-To: <508123AC.5080208@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 19 Oct 2012 13:55:56 +0400

> The SO_BINDTODEVICE option is the only SOL_SOCKET one that can be set, but
> cannot be get via sockopt API. The only way we can find the device id a
> socket is bound to is via sock-diag interface. But the diag works only on
> hashed sockets, while the opt in question can be set for yet unhashed one.
> 
> That said, in order to know what device a socket is bound to (we do want
> to know this in checkpoint-restore project) I propose to make this option
> getsockopt-able and report the respective device index.
> 
> Another solution to the problem might be to teach the sock-diag reporting
> info on unhashed sockets. Should I go this way instead?
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied.  I can't believe we didn't support this when the feature
was added.

I guess we figured that if the application made this setting, then
it knows and doesn't need to query it.
