From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes
 infrequently
Date: Mon, 05 May 2008 16:53:58 -0700 (PDT)
Message-ID: <20080505.165358.79192326.davem@davemloft.net>
References: <20080505155502.3fb16590.akpm@linux-foundation.org>
	<20080505.161806.267621711.davem@davemloft.net>
	<1210035335.7941.180.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, liblit@acm.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753407AbYEEXx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 19:53:58 -0400
In-Reply-To: <1210035335.7941.180.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 05 May 2008 17:55:35 -0700

> The width of hardware counters may also be limited and so periodic
> fetching or DMA may be needed to prevent overflow.

To the best of my knowledge, they are all 64-bit on e1000, so I don't
think it's a real issue in this specific case.

But yes, in general, this is a concern.

