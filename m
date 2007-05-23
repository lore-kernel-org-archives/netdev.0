From: David Miller <davem@davemloft.net>
Subject: Re: IFF_PROMISC again
Date: Tue, 22 May 2007 17:12:25 -0700 (PDT)
Message-ID: <20070522.171225.70219741.davem@davemloft.net>
References: <1178044568.7116.14.camel@abraxas.dyn-o-saur.com>
	<465385F2.7080309@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin.ferrari@gmail.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59022
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756874AbXEWAMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 20:12:22 -0400
In-Reply-To: <465385F2.7080309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 22 May 2007 17:08:18 -0700

> Anyone know the reasoning for masking out the PROMISC flag
> in dev_get_flags() ?

Because promiscuous status is a counter, not a binary
on-off state.

You can't expect to just clear it and expect all the
other promiscuous users to just "go away" and be ok
with the device leaving promiscuous mode.

Since you can't sanely "set" it, we don't provide it
either.
