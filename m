From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 15 Jun 2009 16:18:58 -0700 (PDT)
Message-ID: <20090615.161858.00964937.davem@davemloft.net>
References: <65634d660906142252y6f7fc021l844b172995c10044@mail.gmail.com>
	<20090615.020240.84385988.davem@davemloft.net>
	<65634d660906150939w7a940eegbe74aea7bfbb7f71@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52431
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751455AbZFOXSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 19:18:55 -0400
In-Reply-To: <65634d660906150939w7a940eegbe74aea7bfbb7f71@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 15 Jun 2009 09:39:20 -0700

> There's no lock to put the call_single_data structures onto remote
> CPU's list?  Looking at generic_exec_single...

True, but hopefully that's cheaper than locking the remove
queue.

And also the latency should be much lower for actually
processing the packet.
