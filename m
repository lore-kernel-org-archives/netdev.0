From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH 1/3] PPPoE: improved hashing routine
Date: Tue, 31 Jul 2007 02:16:02 -0700 (PDT)
Message-ID: <20070731.021602.48807945.davem@davemloft.net>
References: <20070731080719.GA12071@florz.florz.dyndns.org>
	<20070731.012609.41193630.davem@davemloft.net>
	<20070731090159.GB12071@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: florz@florz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39102
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752227AbXGaJQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 05:16:02 -0400
In-Reply-To: <20070731090159.GB12071@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@florz.de>
Date: Tue, 31 Jul 2007 11:01:59 +0200

> Assuming that it was supposed to read s/head/hash/: Same disclaimers
> apply, but I'd say this considers only addr&0xff0fff0f000f and
> sid&0x0fff, so, well, yes, it's better, but still not quite what I
> think it should be ;-)

Indeed it's still bogus.

> > Actually it might be simpler and more efficient to just make
> > PPPOE_HASH_SHIFT be 8.
> 
> SHIFT? SIZE? BITS?

You know what I meant :-)

PPPOE_HASH_BITS.

I guess otherwise we degenerate back to your original patch :)
