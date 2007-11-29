From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: wireless vs. alignment requirements
Date: Thu, 29 Nov 2007 09:50:35 -0800
Message-ID: <474EFBEB.5000804@zytor.com>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au> <1195893216.4149.186.camel@johannes.berg> <20071124133200.GA27531@gondor.apana.org.au> <1195912176.4149.194.camel@johannes.berg> <20071124141319.GA27819@gondor.apana.org.au> <4748855C.5090103@linux-foundation.org> <474C50D7.5010901@zytor.com> <20071129131107.GC8487@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>, dsd@gentoo.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:33574 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763229AbXK2Rvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 12:51:37 -0500
In-Reply-To: <20071129131107.GC8487@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Nov 27, 2007 at 09:16:07AM -0800, H. Peter Anvin wrote:
>> I wrote a patch for the IP stack to realign packets if necessary at one 
>> point.  I should dredge it up again and submit it for collective flamage.
> 
> As long as it doesn't penalise Ethernet (e.g., the 10Gb crowd :) it would
> be good to have.
> 
> Thanks,

Uhm, most cards affected *ARE* Ethernet cards, due to the bloody 14-byte 
header.

But it doesn't affect architectures which have alignment, and the cost 
of scanning a properly-aligned packet is minimal.

I'll try to find it some time today.

	-hpa
