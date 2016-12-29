From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] tc: flower: support matching flags
Date: Thu, 29 Dec 2016 10:43:52 -0800
Message-ID: <20161229104352.3408a10d@xeon-e3>
References: <1482930409-55059-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33372 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752895AbcL2Snz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 13:43:55 -0500
Received: by mail-pg0-f46.google.com with SMTP id g1so129939672pgn.0
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 10:43:55 -0800 (PST)
In-Reply-To: <1482930409-55059-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Dec 2016 15:06:49 +0200
Paul Blakey <paulb@mellanox.com> wrote:

> Enhance flower to support matching on flags.
> 
> The 1st flag allows to match on whether the packet is
> an IP fragment.
> 
> Example:
> 
> 	# add a flower filter that will drop fragmented packets
> 	# (bit 0 of control flags)
> 	tc filter add dev ens4f0 protocol ip parent ffff: \
> 		flower \
> 		src_mac e4:1d:2d:fd:8b:01 \
> 		dst_mac e4:1d:2d:fd:8b:02 \
> 		indev ens4f0 \
> 		matching_flags 0x1/0x1 \
> 	action drop
> 
> Signed-off-by: Paul Blakey <paulb@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reviewed-by: Roi Dayan <roid@mellanox.com>

Applied. Had to manually fixup merge conflicts with other flower changes.
