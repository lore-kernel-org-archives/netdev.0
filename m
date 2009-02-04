From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GSO checksum warning debug info
Date: Wed, 4 Feb 2009 23:40:11 +1100
Message-ID: <20090204124011.GA22288@gondor.apana.org.au>
References: <20090204002345.GF5220@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44400 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753523AbZBDMkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 07:40:14 -0500
Content-Disposition: inline
In-Reply-To: <20090204002345.GF5220@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 04:23:45PM -0800, Chris Wright wrote:
> I'm able to trigger the GSO checksum warning, and after 67fd1a73 "net: Add
> debug info to track down GSO checksum bug" here's the more verbose output:
> 
> e1000e: caps=(0x1119a9, 0x0) len=2960 data_len=0 ip_summed=0
> 
> What info would be helpful for you (couple full backtraces below)?

Interesting.  Is this a Linux guest or a Window guest?

If it's a Linux guest, it means that somewhere along the line
the partial checksum got lost.  But I can't see anything obvious.
Since you can reproduce this, could you add some printks along
the path shown in the back trace to see where ip_summed gets
zapped? So that would be tun and bridge basically.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
