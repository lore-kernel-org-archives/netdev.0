From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver
Date: Tue, 02 Feb 2010 17:41:32 -0800 (PST)
Message-ID: <20100202.174132.49841752.davem@davemloft.net>
References: <20100202.134251.15604523.davem@davemloft.net>
	<1265160242.15726.20.camel@hawkeye.sandia.gov>
	<20100202.174045.135005544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ktpedre@sandia.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38724
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932149Ab0BCBlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 20:41:19 -0500
In-Reply-To: <20100202.174045.135005544.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 02 Feb 2010 17:40:45 -0800 (PST)

> From: "Kevin Pedretti" <ktpedre@sandia.gov>
> Date: Tue, 2 Feb 2010 18:24:02 -0700
> 
>> 2. May want to use alloc_netdev() -> Didn't do this. Would there be a
>> substantial advantage to doing this?
> 
> I think you're going to end up having to make this change.

Ignore this, using alloc_etherdev() should be just fine.
