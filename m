From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] Extend Time Stamping
Date: Sun, 18 Jul 2010 19:24:20 -0700 (PDT)
Message-ID: <20100718.192420.146333161.davem@davemloft.net>
References: <cover.1279391885.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55623
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758055Ab0GSCYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 22:24:05 -0400
In-Reply-To: <cover.1279391885.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sat, 17 Jul 2010 20:48:02 +0200

> This patch set extends the packet time stamping capabilites of the
> network stack in two ways.
> 
> 1. The first patch presents a work-around for the TX software time
>    stamping fallback problem cited in cd4d8fdad1f1. The idea is to add
>    one inline function into each MAC driver. This function will act
>    as hooks for current (and possible future) time stamping needs,
>    once they are placed correctly within each MAC driver.
> 
> 2. The other patches prepare the way for PHY drivers to offer time
>    stamping.
> 
> I am preparing a new round of patches for PTP support, but it will
> require the changes in this patch set in order to function. Thus I
> would like to have this patch set reviewed (and hopefully merged) in
> order to go forward.

Ok this looks good enough to me to toss into net-next-2.6

All applied, thanks!
