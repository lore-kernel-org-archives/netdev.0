From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: sk_buff handling in packet handler
Date: Sun, 17 May 2009 00:19:49 +0400
Message-ID: <20090516201949.GA3408@ioremap.net>
References: <4A0EEA60.6090702@accedian.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Claude Robitaille <clauder@accedian.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:50591 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388AbZEPUUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 May 2009 16:20:01 -0400
Content-Disposition: inline
In-Reply-To: <4A0EEA60.6090702@accedian.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 16, 2009 at 12:31:28PM -0400, Claude Robitaille (clauder@accedian.com) wrote:
> I suspect that the handler needs to do something with the sk_buff but I 
> am not sure what. I printed the content of the sk_buff and found that 
> the skb_buff is not cloned (looking on the web I had found that the 
> sk_buff should have been cloned) and that he number of users is 1.
> 
> Should I simply do a dev_kfree_skb? What are the rules governing the use 
> of the sk_buff in a packet handler? Should I clone the sk_buff?
> 
> Also, a related question, the packet handler is expected to return an 
> int. What should be returned?

Use packet socket code as the best documentation, in particular
packet_rcv, but 0 is ok, although in theory it should match NET_RX_*
constants.

-- 
	Evgeniy Polyakov
