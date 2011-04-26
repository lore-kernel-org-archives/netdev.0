From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/3] bql: Byte queue limits
Date: Tue, 26 Apr 2011 09:16:20 -0700
Message-ID: <20110426091620.7c576a98@nehalam>
References: <alpine.DEB.2.00.1104252128290.5895@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37575 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754122Ab1DZQQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 12:16:22 -0400
In-Reply-To: <alpine.DEB.2.00.1104252128290.5895@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Apr 2011 21:38:11 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> Networking stack support for byte queue limits, uses dynamic queue
> limits library.  Byte queue limits are maintained per transmit queue,
> and a bql structure has been added to netdev_queue structure for this
> purpose.
> 
> Configuration of bql is in the tx-<n> sysfs directory for the queue
> under the byte_queue_limits directory.  Configuration includes:
> limit_min, bql minimum limit
> limit_max, bql maximum limit
> hold_time, bql slack hold time
> 
> Also under the directory are:
> limit, current byte limit
> inflight, current number of bytes on the queue
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Although this is implemented as a device attribute, from a layering
point of view it feels like a queuing strategy. Having two competing
ways to do something is not always a good idea. Why is this not a
qdisc parameter or a new qdisc?

-- 
