From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] netpoll: cleanup sparse warnings
Date: Mon, 11 Feb 2013 19:19:51 -0500 (EST)
Message-ID: <20130211.191951.1220001861920410977.davem@davemloft.net>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
	<1360614331-29247-1-git-send-email-nhorman@tuxdriver.com>
	<1360614331-29247-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760679Ab3BLATx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 19:19:53 -0500
In-Reply-To: <1360614331-29247-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 11 Feb 2013 15:25:31 -0500

> With my recent commit I introduced two sparse warnings.  Looking closer there
> were a few more in the same file, so I fixed them all up.  Basic rcu pointer
> dereferencing suff.
> 
> I've validated these changes using CONFIG_PROVE_RCU while starting and stopping
> netconsole repeatedly in bonded and non-bonded configurations
> 
> Signed-offy-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
