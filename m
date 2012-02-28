From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_shifted_skb() adjustment of lost_cnt_hint
 for FACK
Date: Mon, 27 Feb 2012 21:58:20 -0500 (EST)
Message-ID: <20120227.215820.1289745868005567561.davem@davemloft.net>
References: <alpine.DEB.2.00.1202280127490.17924@melkinpaasi.cs.helsinki.fi>
	<alpine.DEB.2.00.1202280141380.18668@melkinpaasi.cs.helsinki.fi>
	<CADVnQym_a=QDyjGX=L6-o3orxPdKJOwVZNfutaW5ZHAt=aB21A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, nanditad@google.com, ycheng@google.com,
	therbert@google.com, subramanian.vijay@gmail.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839Ab2B1C6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 21:58:36 -0500
In-Reply-To: <CADVnQym_a=QDyjGX=L6-o3orxPdKJOwVZNfutaW5ZHAt=aB21A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 27 Feb 2012 21:40:03 -0500

> Yes, I agree that it would make sense to hold off on adding these
> three 3.3-rc4 commits to the stable tree:
> 
> cc9a672ee522d4805495b98680f4a3db5d0a0af9
> 
> daef52bab1fd26e24e8e9578f8fb33ba1d0cb412
> 
> 0af2a0d0576205dda778d25c6c344fc6508fc81d
> 
> It would make sense to let the dust settle a bit more before adding
> those to the stable tree.
> 
> The same goes for the http://patchwork.ozlabs.org/patch/143114/ patch
> (under review) that is in the same area of the code.

I totally disagree and I have submitted those fixes to -stable
already and do not plan to rescind those submissions at all.
