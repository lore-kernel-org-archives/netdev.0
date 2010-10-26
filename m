From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Make the ip6_tunnel reflect the true mtu.
Date: Tue, 26 Oct 2010 10:44:52 -0700 (PDT)
Message-ID: <20101026.104452.70198187.davem@davemloft.net>
References: <1287499123-25018-1-git-send-email-Anders.Franzen@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Anders.Franzen@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48160
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760124Ab0JZRo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:44:29 -0400
In-Reply-To: <1287499123-25018-1-git-send-email-Anders.Franzen@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anders.Franzen@ericsson.com
Date: Tue, 19 Oct 2010 16:38:43 +0200

> From: Anders Franzen <anders.franzen@ericsson.com>
> 
> The ip6_tunnel always assumes it consumes 40 bytes (ip6 hdr) of the mtu of the
> underlaying device. So for a normal ethernet bearer, the mtu of the ip6_tunnel is
> 1460.
> However, when creating a tunnel the encap limit option is enabled by default, and it
> consumes 8 bytes more, so the true mtu shall be 1452.
> 
> I dont really know if this breaks some statement in some RFC, so this is a request for
> comments.

This patch looks fine to me, but please fully resubmit this with a
proper "Signed-off-by: " tag as per Documentation/SubmittingPatches

Thanks.
