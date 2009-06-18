From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Keep index within tab_unreach[]
Date: Thu, 18 Jun 2009 00:26:32 -0700 (PDT)
Message-ID: <20090618.002632.18400816.davem@davemloft.net>
References: <4A39A200.20603@hp.com>
	<20090617.192039.171958637.davem@davemloft.net>
	<4A39BE00.1050506@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45367
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757411AbZFRH02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 03:26:28 -0400
In-Reply-To: <4A39BE00.1050506@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Thu, 18 Jun 2009 00:09:36 -0400

> "type" is a u8 too, but both seem to be passed as int's everywhere (rawv6,
> tcp, sctp and dccp), and in the err_handler() func pointer in the inet6_protocol
> struct.  I can try and cook something up in the next few days that changes
> it all to u8's.

Feel free, thanks a lot.

I'm going to revert Roel's patch since it doesn't fix anything.
