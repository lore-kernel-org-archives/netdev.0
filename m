From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Fri, 12 Mar 2010 14:23:02 -0800
Message-ID: <20100312142302.30def236@nehalam>
References: <alpine.DEB.1.00.1003121210050.25665@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33349 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932699Ab0CLWXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Mar 2010 17:23:23 -0500
In-Reply-To: <alpine.DEB.1.00.1003121210050.25665@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Mar 2010 12:13:12 -0800 (PST)
Tom Herbert <therbert@google.com> wrote:

> if (unlikely(index >= dev->num_rx_queues)) {
> +			if (net_ratelimit()) {
> +				WARN(1, "Received packet on %s for queue %u, "
> +				    "but number of RX queues is %u\n",
> +				     dev->name, index, dev->num_rx_queues);
> +			}
> +			goto done;


Use dev_WARN? or invent netdev_WARN?
