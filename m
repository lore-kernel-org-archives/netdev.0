From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: Don't assume type tun in tun_device_event
Date: Fri, 08 Jul 2016 23:59:20 -0400 (EDT)
Message-ID: <20160708.235920.2218047996694463218.davem@davemloft.net>
References: <1467845060-7502-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbcGID7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 23:59:22 -0400
In-Reply-To: <1467845060-7502-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Wed,  6 Jul 2016 18:44:20 -0400

> From: Craig Gallek <kraig@google.com>
> 
> The referenced change added a netlink notifier for processing
> device queue size events.  These events are fired for all devices
> but the registered callback assumed they only occurred for tun
> devices.  This fix adds a check (borrowed from macvtap.c) to discard
> non-tun device events.
> 
> For reference, this fixes the following splat:
 ...
> Fixes: 1576d9860599 ("tun: switch to use skb array for tx")
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied, thanks.
