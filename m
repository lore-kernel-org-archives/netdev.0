From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock: don't enable netstamp for af_unix
 sockets
Date: Tue, 27 Oct 2015 19:39:39 -0700 (PDT)
Message-ID: <20151027.193939.2131141133181953706.davem@davemloft.net>
References: <1445863897-22646-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755260AbbJ1CW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:22:57 -0400
In-Reply-To: <1445863897-22646-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 26 Oct 2015 13:51:37 +0100

> netstamp_needed is toggled for all socket families if they request
> timestamping. But some protocols don't need the lower-layer timestamping
> code at all. This patch starts disabling it for af-unix.
> 
> E.g. systemd enables timestamping during boot-up on the journald af-unix
> sockets, thus causing the system to globally enable timestamping in the
> lower networking stack. Still, it is very probable that timestamping
> gets activated, by e.g. dhclient or various NTP implementations.
> 
> Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
