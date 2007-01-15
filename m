From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 15 Jan 2007 17:25:37 +0300
Message-ID: <45AB8EE1.2010603@tls.msk.ru>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:20839 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbXAOOZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 09:25:41 -0500
In-Reply-To: <45AB82F1.9000409@tls.msk.ru>
To: unlisted-recipients:; (no To-header on input)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Tokarev wrote:
[]
> And another thing I noticed.  Right now I'm experimenting with another
> machine, running 2.6.17(.13) - it also shows similar behavior with bad
> csums, but MUCH rarer than this 2.6.19.  Like this:
> 
> 16:29:32.490976 IP (tos 0x60, ttl  48, id 14110, offset 0, flags [DF], length: 80)
>  69.42.67.34.2612 > 81.13.94.6.1234: . [bad tcp cksum f4b4 (->c1cc)!] ack 93407 win 9821
>  <nop,nop,timestamp 1046528199 5497679,nop,nop,sack sack 3 {104991:109335}{110783:112231}{104991:109335} >

This seems to be a tcpdump bug.  At least the same packet(s), on another machine
(in-between the two), with updated tcpdump, shows as having correct checksum.
After updating tcpdump on this machine, I'm not seeing this 'sack bad cksum'
stuff anymore.

/mjt
