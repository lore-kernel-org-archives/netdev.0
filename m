From: Marco Berizzi <pupilla@hotmail.com>
Subject: RE: 2.6.26: [<c0133cc1>] __alloc_pages_internal+0x331/0x343
Date: Fri, 25 Jul 2008 21:19:15 +0200
Message-ID: <BAY103-W2394C864310066EAA69D95B2860@phx.gbl>
References: <BAY103-DAV74E605DFBE7CC22EEA732B2870@phx.gbl>
 <E1KMO85-00052z-00@gondolin.me.apana.org.au>
 <20080725141953.GA19418@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s22.bay0.hotmail.com ([65.54.246.222]:49055 "EHLO
	bay0-omc3-s22.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751373AbYGYTTQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 15:19:16 -0400
In-Reply-To: <20080725141953.GA19418@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Herbert Xu wrote:

> On Fri, Jul 25, 2008 at 10:18:45PM +0800, Herbert Xu wrote:
>>
>> Pick one of these:
>>
>> 1) You have less RAM;
>> 2) Your memory fragmentation has deteriorated;
>> 3) Most likely: you were just lucky :)
>
> Actually even more likely, someone

This happened when I started the upgrade from 2.6.25.x to
2.6.26 of my ipsec gateways: it take me few days to do: so,
for a week I have both 2.6.25 and 2.6.26 running.

> has sent you a huge packet
> which triggered this (> 32K if I remember your trace correctly).

this huge packet come from an ipsec tunnel? If yes
linux 2.6.26 is sending this huge packets: this error
happened also on systems where there are only ipsec
tunnels to other linux boxes.
_________________________________________________________________
News, entertainment and everything you care about at Live.com. Get it now!
http://www.live.com/getstarted.aspx