From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: extend hash tables to 256 slots
Date: Tue, 06 Oct 2009 22:29:35 -0700 (PDT)
Message-ID: <20091006.222935.231081303.davem@davemloft.net>
References: <4ACBE3E7.60404@hp.com>
	<4ACC0CDE.1020907@gmail.com>
	<4ACC1C73.1010506@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34159
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754862AbZJGF3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 01:29:40 -0400
In-Reply-To: <4ACC1C73.1010506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Oct 2009 06:43:31 +0200

> David, I believe UDP_HTABLE_SIZE never changed from its initial value of 128,
> defined 15 years ago. Could we bump it to 256 ?
> 
> (back in 1995, SOCK_ARRAY_SIZE was 256)
> 
> (I'll probably use 1024 value for my tests)

That's incredible that it's been that low for so long :-)

Bug please, dynamically size this thing, maybe with a cap of say 64K
to start with.  If you don't have time for it I'll take care of this.
