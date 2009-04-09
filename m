From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 08 Apr 2009 22:24:20 -0700 (PDT)
Message-ID: <20090408.222420.196708386.davem@davemloft.net>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
	<20090408.173607.177460759.davem@davemloft.net>
	<65634d660904082140k727720c5o22f203aa092727a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759288AbZDIFYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 01:24:30 -0400
In-Reply-To: <65634d660904082140k727720c5o22f203aa092727a6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 8 Apr 2009 21:40:28 -0700

> Thanks for the reference to that patch, are you planning to apply it?

Not any time soon.

It eats up a good chunk of space in struct sk_buff but I have
a plan to eliminate most of that which involves moving all of
the SKB queue handling over to "list_head" then we can share
list_head space in "struct call_single_data" using a union.
