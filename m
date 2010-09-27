From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v3] net: af_packet: don't call tpacket_destruct_skb()
	until the skb is sent out
Date: Mon, 27 Sep 2010 05:30:47 +0000
Message-ID: <20100927053046.GA6296@ff.dom.local>
References: <1285236939-3239-1-git-send-email-xiaosuo@gmail.com> <20100924063623.GA6359@ff.dom.local> <20100926.182208.102539866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaosuo@gmail.com, eric.dumazet@gmail.com, socketcan@hartkopp.net,
	mst@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58881 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852Ab0I0Fax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 01:30:53 -0400
Received: by fxm3 with SMTP id 3so1595520fxm.19
        for <netdev@vger.kernel.org>; Sun, 26 Sep 2010 22:30:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100926.182208.102539866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 26, 2010 at 06:22:08PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 24 Sep 2010 06:36:23 +0000
> 
> > af_packet could check some flag which guarantees the queued dev can do
> > skb_orphan after the real xmit and copy buffers otherwise.
> 
> Jarek, we pre-orphan SKBs in the core way before device even gets
> the packet.

I'm not sure which place in the core do you mean; skb_orphan_try() in
dev_hard_start_xmit() depends on ->tx_flags.

Jarek P.
