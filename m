From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 5 of 5] IPv6: temporary address: update the timer for
 tentative addresses
Date: Fri, 28 Mar 2008 12:25:58 +0900 (JST)
Message-ID: <20080328.122558.13389103.yoshfuji@linux-ipv6.org>
References: <patchbomb.1206305168@pirzuine>
	<4765830d9f3848ef14e6.1206305173@pirzuine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: benoit.boissinot@ens-lyon.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55397 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbYC1DY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 23:24:28 -0400
In-Reply-To: <4765830d9f3848ef14e6.1206305173@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4765830d9f3848ef14e6.1206305173@pirzuine> (at Sun, 23 Mar 2008 21:46:13 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:

> IPv6: temporary address: update the timer for tentative addresses
> 
> Even for tentative addresses, we should update the timer,
> otherwise if the preferred lifetime is too short we will
> miss the opportunity to regenerate the adress.

Well, but it this ever happens, it implies that the lifetime
is too short, doesn't it?
We don't want such temporary address too much.

--yoshfuji
