From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: Oops in tun: bisected to  Limit amount of queued packets per device
Date: Wed, 15 Apr 2009 16:30:38 +0200
Message-ID: <m2hc0qrnu9.fsf@igel.home>
References: <200904090952.01175.borntraeger@de.ibm.com>
	<20090409093817.GA5760@gondor.apana.org.au>
	<200904091239.14630.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:59433 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbZDOOao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 10:30:44 -0400
In-Reply-To: <200904091239.14630.borntraeger@de.ibm.com> (Christian
	Borntraeger's message of "Thu, 9 Apr 2009 12:39:14 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian Borntraeger <borntraeger@de.ibm.com> writes:

> No, I was booting up a guest and the guest sent its first packet (arp). I 
> forgot to mention, that the tap device is persistent and attached to a 
> bridge. Does that give a clue?

Being persistent appears to make the difference.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
