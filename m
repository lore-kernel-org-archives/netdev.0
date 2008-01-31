From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] Optimize cxgb3 xmit path (a bit)
Date: Wed, 30 Jan 2008 16:04:35 -0800
Message-ID: <47A11093.10301@chelsio.com>
References: <20080130070016.29078.94125.sendpatchset@N20wks267652wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:19033 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123AbYAaAfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 19:35:17 -0500
In-Reply-To: <20080130070016.29078.94125.sendpatchset@N20wks267652wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar wrote:
> Changes:
> 	1. Add common code for stopping queue.
> 	2. No need to call netif_stop_queue followed by netif_wake_queue (and
> 	   infact a netif_start_queue could have been used instead), instead
> 	   call stop_queue if required, and remove code under USE_GTS macro.
> 	3. There is no need to check for netif_queue_stopped, as the network
> 	   core guarantees that for us (I am sure every driver could remove
> 	   that check, eg e1000 - I have tested that path a few billion times
> 	   with about a few hundred thousand qstops but the condition never
> 	   hit even once).
>
> Thanks,
>   

Hi Krishna,

Thanks for the work.
There is however a bit more cleaning to do regarding the USE_GTS macro.
I'll post a patch soon that will take your points in account.

Cheers,
Divy
