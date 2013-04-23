From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Tue, 23 Apr 2013 13:33:15 -0400 (EDT)
Message-ID: <20130423.133315.1278191592594257624.davem@davemloft.net>
References: <20130423132345.GA5564@hmsreliant.think-freely.org>
	<CAO+b5-rQPyO9QE9v+oQTeo+G-ftcsehSB5=63AZ13QW4EJ1X0Q@mail.gmail.com>
	<20130423134443.GB5564@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bart.vanassche@gmail.com, netdev@vger.kernel.org, mingo@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756769Ab3DWRdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 13:33:17 -0400
In-Reply-To: <20130423134443.GB5564@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 23 Apr 2013 09:44:43 -0400

> Dave, how do you feel about it?  I'm comfortable with the wait queue change I've
> proposed, but I've not received any reports of actual netpoll deadlocks (i.e.
> the mutex solution is reporting a warning, but no actual problems).  So I think
> its safe to wait a bit longer, unless you just want this squared away now.

If it's just a warning and people aren't actually hitting the
potential deadlock, it can wait.
