From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 10:56:44 -0700 (PDT)
Message-ID: <20100426.105644.71114735.davem@davemloft.net>
References: <1272302434.19143.76.camel@edumazet-laptop>
	<q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
	<1272304072.2376.10.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49895
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751128Ab0DZR4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 13:56:38 -0400
In-Reply-To: <1272304072.2376.10.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 26 Apr 2010 18:47:52 +0100

> Unfortunately the widely-implemented Toeplitz hash functions are defined
> only for TCP/IPv4, TCP/IPv6, IPv4 and IPv6.

What a complete and utter waste all of this is then.

Defining the hash as TCP only is about as stupid as making hw checksum
offload be TCP only.

Really, I'm completely stunned.
