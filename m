From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after
	some time
Date: Mon, 1 Sep 2008 11:09:59 +0200
Message-ID: <20080901090959.GA6621@schleppi.birkenwald.de>
References: <20080831182034.GA12035@pest> <OF94B2D0C1.33DB4CE6-ON882574B7.001FDB00-882574B7.00200870@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:59235 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757487AbYIAKBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 06:01:39 -0400
Content-Disposition: inline
In-Reply-To: <OF94B2D0C1.33DB4CE6-ON882574B7.001FDB00-882574B7.00200870@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 31, 2008 at 10:49:50PM -0700, David Stevens wrote:

Hello David,

> My wild guess is that you have lost the multicast bit on
> the interface, by a daemon that is just setting the interface
> flags rather than doing get/or in new/set.
> 
> When it's failing, you might try looking at the interface
> flags to see if IFF_MULTICAST is still there.

It is. miredo isn't doing anything with the eth0 interface, and I can
still reach other multicast groups on te same interface.

Bernhard
