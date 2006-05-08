From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Initial benchmarks of some VJ ideas [mmap memcpy vs
 copy_to_user].
Date: Mon, 08 May 2006 13:15:47 -0700 (PDT)
Message-ID: <20060508.131547.73910171.davem@davemloft.net>
References: <20060508122418.GA22554@2ka.mipt.ru>
	<20060508195132.GB19091@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59272
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750773AbWEHUR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 16:17:28 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060508195132.GB19091@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 8 May 2006 23:51:32 +0400

> Since nocopy is actually equal to dma into mapped buffer,
> so we get something close to 6 times less CPU usage, and if it can be
> lineary transferred into performance gain, we found where the most
> significant part of VJ channels lives.

Van's machines were cpu limited.  And once cpu limit was removed,
they became bus bandwidth limited.

> Unfortunately it is not backward compatible with recv() system call,
> and requires major changes in application to use this advantage.

I have stopped believing that compatible API for getting top
performance in networking receive is possible a very long time ago.

ABI change is an absolutely requirement.
