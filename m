From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] batman-adv: Use packing of 2 for all headers
 before an ethernet header
Date: Wed, 21 Nov 2012 12:57:59 -0500 (EST)
Message-ID: <20121121.125759.322762083309845086.davem@davemloft.net>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org>
	<1353499919-28596-10-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	sven@narfation.org, lindner_marek@yahoo.de
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470Ab2KUR6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 12:58:01 -0500
In-Reply-To: <1353499919-28596-10-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Wed, 21 Nov 2012 13:11:59 +0100

> +#pragma pack(2)
 ...
> -} __packed;

The __packed attribute is an abstraction of the actual syntax
the compiler uses, if it is supported at all.

Therefore, you can't just unconditionally use the #pragma, and
you would need to use some kind of similar compiler abstraction
for it.

But to be honest this is really ugly and for very little, if any,
gain.
