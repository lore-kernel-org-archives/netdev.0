From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why do we use RX queue mapping for TX?
Date: Wed, 18 Feb 2015 16:16:32 -0800
Message-ID: <1424304992.4942.109.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7MXF-KHZ3aeBwwshSYDswKwrjhbMJQ=+Hfj3gZJq70dXQ@mail.gmail.com>
	 <CAHA+R7PdG+jDqFA1jDFzHtkrxqLEZdtj1w5QyrdYMO4fX6+A1w@mail.gmail.com>
	 <CAHA+R7OVHgwQBM200UZDKiw5eypuzhWj=B4E3MRkOK3yViZDCQ@mail.gmail.com>
	 <1424301248.4942.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7PbLRw-oA4v9ivZ0s-++ALx99zddJLDqDoemyBTc2XZ1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:48536 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbBSAQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 19:16:34 -0500
Received: by mail-ig0-f182.google.com with SMTP id h15so5848888igd.3
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 16:16:33 -0800 (PST)
In-Reply-To: <CAHA+R7PbLRw-oA4v9ivZ0s-++ALx99zddJLDqDoemyBTc2XZ1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-18 at 15:57 -0800, Cong Wang wrote:

> I am aware of it. I even would guess (means not digging the history)
> skb_edit was invented for bonding queue mapping, since I don't see it
> even works as a general TC action on the physical interface. We pick
> the tx queue prior to getting the Qdisc, therefore too late to set
> skb->queue_mapping to specify a hardware TX queue. This is
> another story I planned to bring it up to David.

skbedit can be done on ingress I presume.
