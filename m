From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 15:23:54 -0700 (PDT)
Message-ID: <20070829.152354.39168348.davem@davemloft.net>
References: <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>
	<20070829.144656.104048365.davem@davemloft.net>
	<5640c7e00708291510p778f387w51d50e981ba49a25@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: ian.mcdonald@jandi.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56695
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761001AbXH2WX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 18:23:58 -0400
In-Reply-To: <5640c7e00708291510p778f387w51d50e981ba49a25@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 30 Aug 2007 10:10:37 +1200

> Understand what you are saying. That is why I questioned as 200 msecs
> makes no sense on a LAN with < 1 msec RTT. So if the current is
> ridiculous and 1000 is even more so, why do we use? Just because that
> is how TCP is written I'm guessing.

We considered getting rid of the lower bound several times, but didn't
want to investigate it fully back then.

> I know that in DCCP CCID3 the RTO is 4 x RTT (from memory - it might
> be a slight variation) but we ended up putting a minimum on it as you
> also face a problem if it fires too frequently (i.e. link is in
> usecs).
> 
> I might ask around on research lists and see why this issue has never
> been revisited.

There is also the argument that on a local lan congestion control
stops to make any sense.  The problem it that you can't detect what is
a local lan, and any config knob to indicate this is an unacceptable
hack.

Any "congestion" you see on a local high speed lan will be gone before
you can react to it, so it's pretty pointless to do anything.
