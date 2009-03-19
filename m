From: David Miller <davem@davemloft.net>
Subject: Re: iproute2: prints bogus hoplimit
Date: Wed, 18 Mar 2009 18:06:44 -0700 (PDT)
Message-ID: <20090318.180644.37715957.davem@davemloft.net>
References: <20090318151216.60cd0363@nehalam>
	<20090318.175109.14058201.davem@davemloft.net>
	<20090318180106.5115c0aa@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57915
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751340AbZCSBG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:06:57 -0400
In-Reply-To: <20090318180106.5115c0aa@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 18 Mar 2009 18:01:06 -0700

> if I create route with:
>    ip route add ... hoplimit 0
> then to do
>    ip route show 
> one would expect the hoplimit in the show to match the add ??
> Whether the kernel fudges it in rt6_fill or utility has special case
> code really doesn't matter.

Even if the kernel should change, the tool should behave correctly
for all existing Linux kernels out there so you'd need the iproute2
hack anyways.

> The correct patch in utility would be something like:

Sure.
