From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: make last_rx timestamp private
Date: Wed, 02 Sep 2009 14:37:55 -0700 (PDT)
Message-ID: <20090902.143755.109474596.davem@davemloft.net>
References: <20090901.182127.96935772.davem@davemloft.net>
	<20090902105535.GB402@hmsreliant.think-freely.org>
	<20090902133620.GC402@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54856
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751266AbZIBVhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 17:37:40 -0400
In-Reply-To: <20090902133620.GC402@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 2 Sep 2009 09:36:20 -0400

> Ok, heres a repost, unchanged saved for being massaged to fit in with the recent
> changes that my origional patch raced against.  Thanks!
> Neil
> 
> 
> It was recently pointed out to me that the last_rx field of the net_device
> structure wasn't updated regularly.  In fact only the bonding driver really uses
> it currently.  Since the drop_monitor code relies on the last_rx field to detect
> drops on recevie in hardware, We need to find a more reliable way to rate limit
> our drop checks (so that we don't check for drops on every frame recevied, which
> would be inefficient.  This patch makes a last_rx timestamp that is private to
> the drop monitor code and is updated for every device that we track.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.
