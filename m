From: David Miller <davem@davemloft.net>
Subject: Re: TCP and reordering
Date: Tue, 27 Nov 2012 21:06:11 -0500 (EST)
Message-ID: <20121127.210611.1127622873924794001.davem@davemloft.net>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
	<50B4F2DA.8020206@hp.com>
	<CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: saku@ytti.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab2K1CGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 21:06:16 -0500
In-Reply-To: <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saku Ytti <saku@ytti.fi>
Date: Tue, 27 Nov 2012 19:15:20 +0200

> TCP used to be friendly to reordering before fast retransmit
> optimization was implemented.

You're talking about 20 years ago, because that's when fast
retrasnmit was created.

It's not like this got added recently.

And the gains of fast retransmit far outweigh whatever strange
justification would give for reordering packets on purpose.
