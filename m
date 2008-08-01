From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: MD5: Fix IPv6 signatures
Date: Thu, 31 Jul 2008 21:36:28 -0700 (PDT)
Message-ID: <20080731.213628.174118396.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069051@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43665
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752174AbYHAEg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 00:36:28 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069051@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Thu, 31 Jul 2008 21:31:31 -0700

> Reported by Stefanos Harhalakis; although 2.6.27-rc1 talks to itself using IPv6
> TCP MD5 packets just fine, Stefanos noted that tcpdump claimed that the
> signatures were invalid.
> 
> I broke this in 49a72dfb8814c2d65bd9f8c9c6daf6395a1ec58d ("tcp: Fix MD5
> signatures for non-linear skbs"), it was just a typo.
> 
> Note that tcpdump will still sometimes claim that the signatures are incorrect.
> A patch to tcpdump has been submitted for this[1].
> 
> [1] http://tinyurl.com/6a4fl2
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

Applied, and thanks a lot for composing the SHA ID reference properly
this time!
