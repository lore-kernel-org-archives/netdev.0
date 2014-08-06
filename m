From: David Miller <davem@davemloft.net>
Subject: Re: IPv6 over IEEE 802.15.4 aka 6LoWPAN - Neighbor discovery issue
Date: Wed, 06 Aug 2014 14:26:56 -0700 (PDT)
Message-ID: <20140806.142656.1615174630283176908.davem@davemloft.net>
References: <20140805121516.GB14196@omega>
	<53E1797C.8000207@miraclelinux.com>
	<20140806103642.GA32302@omega>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-wpan@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43916 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063AbaHFV05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 17:26:57 -0400
In-Reply-To: <20140806103642.GA32302@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Wed, 6 Aug 2014 12:36:44 +0200

> I can't also use ARPHRD_6LOWPAN otherwise bluetooth will do these
> 802.15.4 specific things in neighbor discovery.

Have the ndisc handlers look at what the underlying device actually
is.
