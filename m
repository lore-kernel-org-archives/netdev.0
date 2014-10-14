From: David Miller <davem@davemloft.net>
Subject: Re: TCP socket receives strange packet
Date: Tue, 14 Oct 2014 12:50:04 -0400 (EDT)
Message-ID: <20141014.125004.1504941413142780868.davem@davemloft.net>
References: <1413298852.17109.3.camel@edumazet-glaptop2.roam.corp.google.com>
	<CABrhC0=y745PHJdmKvPeyiYNAEUX_CHPZo7ekiWJYxLt=pYEkw@mail.gmail.com>
	<20141014164144.GG28432@Paaschs-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, eric.dumazet@gmail.com,
	Yurij.Plotnikov@oktetlabs.ru, netdev@vger.kernel.org,
	Alexandra.Kossovsky@oktetlabs.ru
To: christoph.paasch@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbaJNQuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 12:50:07 -0400
In-Reply-To: <20141014164144.GG28432@Paaschs-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@gmail.com>
Date: Tue, 14 Oct 2014 09:41:44 -0700

> there was a long discussion whether for the updated version of RFC1323 (now
> published as RFC 7323) a segment must be dropped if it does not contain a
> timestamp. The rationale (defended by Joe Touch) was that it must be there to
> protect against wrapped sequence numbers while others argued that mandating
> a drop might result in stalling connections if (for one reason or another) a
> host sends a segment without TS (or a middlebox removed it).
> 
> The RFC now says that a host SHOULD drop segments without timestamps.

There are too many middle-boxes that drop timestamps for that to be a tenable
way to behave, especially by default.

If you want to be disconnected from various parts of the internet, feel free
to follow that RFC's recommendations.
