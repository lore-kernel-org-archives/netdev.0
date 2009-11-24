From: David Miller <davem@davemloft.net>
Subject: Re: NUMA and multiQ interation
Date: Tue, 24 Nov 2009 12:10:17 -0800 (PST)
Message-ID: <20091124.121017.231454645.davem@davemloft.net>
References: <65634d660911240904y294ea6fj4cf2e4ac757e619b@mail.gmail.com>
	<20091124.100613.240222762.davem@davemloft.net>
	<65634d660911241151q4d7522c0nf9c2e4667c333185@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37617
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932829AbZKXUJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 15:09:59 -0500
In-Reply-To: <65634d660911241151q4d7522c0nf9c2e4667c333185@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 24 Nov 2009 11:51:39 -0800

> I saw that thread, and it looks compelling.  But we have applications
> that are network bound such that we want to use multiple queues across
> multiple nodes for scaling-- and trying keep all queues on the same
> node does not scale very well.  Maybe ignoring NUMA allocation could
> be a fall-back mode in a dynamic allocation with heavy load?

You use the word "But" as if what PJ and friends are doing is different
from what you're trying to achive.  I think they are the same.
