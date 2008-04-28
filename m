From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: fix queue limiting while enqueuing
Date: Mon, 28 Apr 2008 16:58:37 +0200
Message-ID: <20080428145837.GB2870@ami.dom.local>
References: <20080427142216.GB7480@ami.dom.local> <4814C618.3050506@trash.net> <20080427203630.GA9648@ami.dom.local> <4815D8D9.5020201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.228]:42766 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933088AbYD1PA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 11:00:27 -0400
Received: by hu-out-0506.google.com with SMTP id 19so1421526hue.21
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 08:00:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4815D8D9.5020201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2008 at 04:02:01PM +0200, Patrick McHardy wrote:
...
> I would go for a new parameter, tx_queue_len is not very well
> suited in my opinion since its global for the entire device,
> and most likely you don't want inner qdiscs to have the full
> tx_queue_length as limit but something smaller.

Yes, a new parameter looks like the safest choice. I'll only have to
re-think first the possible reason for this strange limit...

Thanks again,
Jarek P. 
