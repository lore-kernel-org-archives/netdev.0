From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes
 infrequently
Date: Mon, 05 May 2008 18:17:04 -0700
Message-ID: <1210036624.7941.183.camel@dell>
References: <bug-10600-10286@http.bugzilla.kernel.org/>
 <20080505155502.3fb16590.akpm@linux-foundation.org>
 <20080505.161806.267621711.davem@davemloft.net>
 <481F9E64.6070606@acm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: "Ben Liblit" <liblit@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4994 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753298AbYEFAMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 20:12:35 -0400
In-Reply-To: <481F9E64.6070606@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-05-05 at 18:55 -0500, Ben Liblit wrote:
> Perhaps userspace needs a way to tweak the update frequency?  Or perhaps 
> the driver needs a way to tell userspace what update frequency it should 
> expect?  Without some kind of coordination, we have the present silly 
> situation: userspace network activity monitors are checking rx_bytes 
> more frequently than could possibly be useful.
> 
> Do different Ethernet drivers update rx_bytes at the same rate?  Or is 
> this completely ad hoc?

"ethtool -C eth0 stats-block-usecs" can be used to control statistics
update frequency on most tg3 and bnx2 devices.  The default is 1 second
on these devices.

