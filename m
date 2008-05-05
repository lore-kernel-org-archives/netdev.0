From: Ben Liblit <liblit@acm.org>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes infrequently
Date: Mon, 05 May 2008 18:55:16 -0500
Message-ID: <481F9E64.6070606@acm.org>
References: <bug-10600-10286@http.bugzilla.kernel.org/>	<20080505155502.3fb16590.akpm@linux-foundation.org> <20080505.161806.267621711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pumice.cs.wisc.edu ([128.105.6.29]:45649 "EHLO
	pumice.cs.wisc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754804AbYEEX4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 19:56:22 -0400
In-Reply-To: <20080505.161806.267621711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Perhaps userspace needs a way to tweak the update frequency?  Or perhaps 
the driver needs a way to tell userspace what update frequency it should 
expect?  Without some kind of coordination, we have the present silly 
situation: userspace network activity monitors are checking rx_bytes 
more frequently than could possibly be useful.

Do different Ethernet drivers update rx_bytes at the same rate?  Or is 
this completely ad hoc?
