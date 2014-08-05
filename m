From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/6] net-timestamp: new tx tstamps and tcp
Date: Tue, 05 Aug 2014 16:36:37 -0700 (PDT)
Message-ID: <20140805.163637.1158175402127833659.davem@davemloft.net>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbaHEXgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:36:39 -0400
In-Reply-To: <1407204710-21778-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Mon,  4 Aug 2014 22:11:44 -0400

> Extend socket tx timestamping:
> - allow multiple types of software timestamps aside from send (1)
> - add software timestamp on enter packet scheduling (4)
> - add software timestamp for TCP (5)
> - add software timestamp for TCP on ACK (6)
> 
> The sk_flags option space is nearly exhausted. Also move the
> many timestamp options to a new sk->sk_tstamps (2).
> 
> To disambiguate data when tstamps may arrive out of order,
> optionally return a sequential ID assigned at send (3).
> 
> Extend Linux tx timestamping to monitoring of latency
> incurred within the kernel stack and to protocols embedded in TCP.
> Complex kernel setups may have multiple layers of queueing, including
> multiple instances of packet scheduling, and many classes per layer.
> Many applications embed discrete payloads into TCP bytestreams for
> reliability, flow control, etcetera. Detecting application tail
> latency in such scenarios relies on identifying the exact queue
> responsible if on the host, or the network latency if otherwise.

This looks really good, thanks for taking the time to refine the
interface and how the internal sequence numbering works.

Applied to net-next.
