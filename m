From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC] net : add tx timestamp to packet mmap.
Date: Thu, 13 Dec 2012 19:17:33 +0100
Message-ID: <20121213181733.GA2312@netboy.at.omicron.at>
References: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr>
 <20121213132916.GB10703@netboy.at.omicron.at>
 <50C9FEC4.5050804@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61572 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715Ab2LMSRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 13:17:44 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so1270120bkw.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 10:17:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <50C9FEC4.5050804@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 05:13:56PM +0100, Paul Chavent wrote:
> >
> >In order for time stamps to appear, somebody has to call
> >skb_tx_timestamp() ...
> Yes. "Somebody" means "the hardware driver" after completing xmit.
> That's true ?

Yes, the MAC driver must call this helper function, but not many
drivers do this yet. You didn't say which MAC driver you are using and
whether it supports Tx SO_TIMESTAMPING or not.

> Yes, it only sets some flags. I thought that those flags was
> required by the skb_tx_timestamp() in order to make the appropriate
> timestamping (hardware, software, etc).
> 
> So in order to have tx timestamp that work, both calls are needed ?

Yes.
 
> Why sock_tx_timestamp is called in packet_fill_skb and
> packet_sendmsg_spkt and not in tpacket_fill_skb ?
> Why i can retrieve timestamps when i add this call ?

Sorry, I don't know much about packet mmap. Last time I tried it, some
years ago, it wasn't really working.

Richard
