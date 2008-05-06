From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes
 infrequently
Date: Mon, 05 May 2008 17:55:35 -0700
Message-ID: <1210035335.7941.180.camel@dell>
References: <bug-10600-10286@http.bugzilla.kernel.org/>
 <20080505155502.3fb16590.akpm@linux-foundation.org>
 <20080505.161806.267621711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, liblit@acm.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3815 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbYEEXvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 19:51:09 -0400
In-Reply-To: <20080505.161806.267621711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-05-05 at 16:18 -0700, David Miller wrote:
> Actually, the thing that matters is when ->get_stats() is called.
> 
> So if a driver can trigger a statistics DMA update at ->get_stats()
> time, that's probably what it should do.  But this could get
> expensive and make the "do DMA less often" optimization less useful.
> 
> 

The width of hardware counters may also be limited and so periodic
fetching or DMA may be needed to prevent overflow.

