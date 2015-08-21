From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC 00/10] socket sendmsg MSG_ZEROCOPY
Date: Thu, 20 Aug 2015 22:17:59 -0700 (PDT)
Message-ID: <20150820.221759.895380909053732965.davem@davemloft.net>
References: <1440081408-12302-1-git-send-email-willemb@google.com>
	<20150820.155647.106500427975157613.davem@davemloft.net>
	<CA+FuTSfA=_1VPFbUAh+5_+Xa_UxuTiFgGPGVRzfEtZLkvW6a9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbbHUFSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 01:18:02 -0400
In-Reply-To: <CA+FuTSfA=_1VPFbUAh+5_+Xa_UxuTiFgGPGVRzfEtZLkvW6a9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 20 Aug 2015 22:49:25 -0400

> But there may still be others. Most obvious use case for copy
> avoidance is pure device transmit. Excluding loopback may be
> a reasonable way to initially limit the attack surface. With a flag
> NETIF_F_ZC not supported on lo.

Good luck avoiding every case where a packet can be looped back into
the machine in some way.  A simple device flag is not going to do it.
