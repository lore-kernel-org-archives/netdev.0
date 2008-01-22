From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 9/10][NETNS][FRAGS]: Make the LRU list per
 namespace.
Date: Tue, 22 Jan 2008 06:11:58 -0800 (PST)
Message-ID: <20080122.061158.237231454.davem@davemloft.net>
References: <4795F524.8060204@openvz.org>
	<4795F8F6.5050802@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754221AbYAVOLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:11:51 -0500
In-Reply-To: <4795F8F6.5050802@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jan 2008 17:08:54 +0300

> The inet_frags.lru_list is used for evicting only, so we have
> to make it per-namespace, to evict only those fragments, who's
> namespace exceeded its high threshold, but not the whole hash.
> Besides, this helps to avoid long loops  in evictor.
> 
> The spinlock is not per-namespace because it protects the 
> hash table as well, which is global.
>     
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
