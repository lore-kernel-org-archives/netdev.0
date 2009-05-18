From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sk_buff handling in packet handler
Date: Sun, 17 May 2009 22:38:47 -0700
Message-ID: <20090517223847.168d9ebd@nehalam>
References: <20090517102548.0a55d5bd.ipng@69706e6720323030352d30312d31340a.nosense.org>
	<4A104825.4000201@accedian.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>,
	netdev@vger.kernel.org
To: Claude Robitaille <clauder@accedian.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59787 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756AbZERFiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 01:38:52 -0400
In-Reply-To: <4A104825.4000201@accedian.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 May 2009 13:23:49 -0400
Claude Robitaille <clauder@accedian.com> wrote:

> Thanks Mark.
> 
> very interesting
> 
> this helped me but just to get to next problem....
> 
> what I am trying to do is to receive frame using a packet handler, 
> manipulate it and send a portion of it over a UDP channel. I am using 
> sock_sendmsg. Things sort of work but I get some warnings while in 
> net_tx_action (via the sendmsg I am guessing) about doing scheduling 
> while in atomic and sometime the kernel simply completely crashes. All 
> this probably means that using kernel socket functions cannot be used 
> from any context.... Any suggestion on how to properly do this? 
> Ultimately, I'd like to avoid copying the data so if I could simply send 
> an skb to some UDP TX handler would be ideal but if not, what is the 
> best approach?
> 

Write a netfilter module, it is easier to do what you are trying to
do with iptables rules.

> 


-- 
