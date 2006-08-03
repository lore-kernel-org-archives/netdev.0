From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 16:56:54 -0700 (PDT)
Message-ID: <20060803.165654.45876296.davem@davemloft.net>
References: <20060803201741.GA7894@thunk.org>
	<20060803.144845.66061203.davem@davemloft.net>
	<20060803235326.GC7894@thunk.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31672
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030230AbWHCX4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 19:56:52 -0400
To: tytso@mit.edu
In-Reply-To: <20060803235326.GC7894@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Theodore Tso <tytso@mit.edu>
Date: Thu, 3 Aug 2006 19:53:26 -0400

> Any suggestions on how I could figure out what was really going on and
> what would be a better fix would be greatly appreciated.

As Michael explained, it's the ASF heartbeat sent by tg3_timer() that
must be delivered to the chip within certain timing constraints.

If you had any watchdog devices on this machine, they would likely
trigger too and reset your machine :)
