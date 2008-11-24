From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] pkt_sched: sch_drr: Fix drr_dequeue() loop
Date: Mon, 24 Nov 2008 12:51:50 +0000
Message-ID: <20081124125150.GB16755@ff.dom.local>
References: <20081120113557.GA5275@ff.dom.local> <49254D42.10506@trash.net> <20081124105345.GB13957@ff.dom.local> <492A9ACB.4050504@trash.net> <20081124123349.GA16755@ff.dom.local> <492AA058.9060302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:7626 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbYKXMv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 07:51:56 -0500
Received: by ug-out-1314.google.com with SMTP id 39so724659ugf.37
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 04:51:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <492AA058.9060302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2008 at 01:38:48PM +0100, Patrick McHardy wrote:
...
> TBF with an inner DRR is fine. The other way around is broken
> in the sense that the behaviour is undefined.

IMHO, this other way (e.g. a class with TBF per user), should work too.

BTW, since this "broken" config isn't very apparent, maybe you should
add some warning?

Jarek P. 
