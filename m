From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/3] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Sun, 22 Feb 2015 15:47:33 -0500 (EST)
Message-ID: <20150222.154733.112061471461322123.davem@davemloft.net>
References: <1423715535-884-3-git-send-email-eyal.birger@gmail.com>
	<20150219.150500.834870317013347277.davem@davemloft.net>
	<CAHsH6Gv709dahHUGqXkb8CYxn+s0-4+1DGksoNfAgMksZYrt9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	shmulik.ladkani@gmail.com
To: eyal.birger@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbbBVUrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 15:47:36 -0500
In-Reply-To: <CAHsH6Gv709dahHUGqXkb8CYxn+s0-4+1DGksoNfAgMksZYrt9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Birger <eyal.birger@gmail.com>
Date: Fri, 20 Feb 2015 13:32:48 +0200

> However, It seems the skb is cloned prior to setting dropcount and
> other skb header fields before it is enqueued in packet_rcv(). Would
> that not prevent interference with the transmit path?

You're right, that should take care of all cases.

Please resubmit this series, perhaps adding some commit
log text explaining this for the next person who reads
these changes.
