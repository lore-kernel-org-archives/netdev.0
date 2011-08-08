From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Mon, 8 Aug 2011 08:40:16 -0700
Message-ID: <20110808084016.063a0699@nehalam.ftrdhcpuser.net>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45994 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877Ab1HHPkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 11:40:07 -0400
In-Reply-To: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 7 Aug 2011 21:43:13 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

>     netdev_tx_completed_queue: Called at end of transmit completion
>       to inform stack of number of bytes and packets processed.
>     netdev_tx_sent_queue: Called to inform stack when packets are
>       queued.

Couldn't these be done for the device in the existing qdisc infra
structure (or dev_start_xmit). Alternatively, rename ndo_start_xmit
to something else and make all the callers use the wrapper.

Changing all the drivers for something that the driver has no real
need to care about seems like incorrect object design.
