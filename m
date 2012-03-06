From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: runtime resume before shutdown.
Date: Tue, 06 Mar 2012 15:15:03 -0500 (EST)
Message-ID: <20120306.151503.848145173320023273.davem@davemloft.net>
References: <20120306111412.GA1805@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com, snanda@chromium.org,
	rjw@sisk.pl, stern@rowland.harvard.edu
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030983Ab2CFUQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 15:16:35 -0500
In-Reply-To: <20120306111412.GA1805@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 6 Mar 2012 12:14:12 +0100

> With runtime PM, if the ethernet cable is disconnected, the device is
> transitioned to D3 state to conserve energy. If the system is shutdown
> in this state, any register accesses in rtl_shutdown are dropped on
> the floor. As the device was programmed by .runtime_suspend() to wake
> on link changes, it is thus brought back up as soon as the link recovers.
> 
> Resuming every suspended device through the driver core would slow things
> down and it is not clear how many devices really need it now.
> 
> Original report and D0 transition patch by Sameer Nanda. Patch has been
> changed to comply with advices by Rafael J. Wysocki and the PM folks.
> 
> Reported-by: Sameer Nanda <snanda@chromium.org>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Rafael J. Wysocki <rjw@sisk.pl>
> Cc: Hayes Wang <hayeswang@realtek.com>
> Cc: Alan Stern <stern@rowland.harvard.edu>
> ---
> 
>  This sucker turned my silent wake-on-alarm workstation into an early
>  sunday morning testbed takeoff. Please consider before 3.3 goes out.

Applied.
