From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] skb: avoid unnecessary reallocations in __skb_cow
Date: Tue, 29 May 2012 15:26:07 +0200
Message-ID: <1338297967.2840.31.camel@edumazet-glaptop>
References: <1338132370-88299-1-git-send-email-nbd@openwrt.org>
	 <1338294848.2840.15.camel@edumazet-glaptop> <4FC4C3E8.6080206@openwrt.org>
	 <1338296361.2840.23.camel@edumazet-glaptop> <4FC4CAB1.8010000@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37716 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab2E2N0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 09:26:14 -0400
Received: by eeit10 with SMTP id t10so1082659eei.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 06:26:14 -0700 (PDT)
In-Reply-To: <4FC4CAB1.8010000@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-29 at 15:10 +0200, Felix Fietkau wrote:

> I don't have any real use case in mind, but it's not really adding an
> extra NET_SKB_PAD, it simply fills up the headroom to NET_SKB_PAD,

This is not what is doing your patch.

If cloned is true, and current skb headroom less than 64, you add an
extra 64 bytes of headroom.

Just keep it simple, this is inline code and should be kept as small as
possible.
