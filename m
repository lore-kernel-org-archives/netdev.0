From: David Miller <davem@davemloft.net>
Subject: Re: Softirqs without captured packets
Date: Fri, 08 Feb 2013 14:57:28 -0500 (EST)
Message-ID: <20130208.145728.1110053781319882182.davem@davemloft.net>
References: <CALZVap=wdDnTndwa+Q+MLCufj9YpY-m+wATFiKSTX2bXX-9DVw@mail.gmail.com>
	<CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: javierdo1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946882Ab3BHT53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 14:57:29 -0500
In-Reply-To: <CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Domingo <javierdo1@gmail.com>
Date: Fri, 8 Feb 2013 20:54:14 +0100

> Just realized I didn't put the file:

Softirqs happen for TX packet reclaim, other miscelanneous networking
device events (link status changes, hw statistic overflows, etc.),
timers, etc.

They are not exclusively triggered for receive packets.
