From: David Miller <davem@davemloft.net>
Subject: Re: netem and hierarchical ingress traffic shaping
Date: Fri, 23 Dec 2011 14:36:53 -0500 (EST)
Message-ID: <20111223.143653.1443323405556018049.davem@davemloft.net>
References: <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
	<1324664907.2915.5.camel@edumazet-laptop>
	<20111223110749.7a690685@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, dave.taht@gmail.com,
	jsullivan@opensourcedevel.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453Ab1LWTg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 14:36:58 -0500
In-Reply-To: <20111223110749.7a690685@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 23 Dec 2011 11:07:49 -0800

> So basically, netem, choke, and sfb are incompatible with
> each other. This is not that bad, why not add a flag to qdisc
> ops to indicate which qdisc are using cb and block user from
> trying to do something bogus.

Or we could do what we do in the inet stack, define a layout
that allows the different layers to use different parts of the
CB.
