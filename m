From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 06:55:51 +0000
Message-ID: <20081008065551.GB4174@ff.dom.local>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:27208 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbYJHGz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 02:55:59 -0400
Received: by ug-out-1314.google.com with SMTP id k3so479136ugf.37
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2008 23:55:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48EBFF5E.1090902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 02:31:26AM +0200, Patrick McHardy wrote:
...
> I'm pretty sure that the differences are caused by HTB not being
> in control of the queue since the device is the real bottleneck
> in this configuration.

Yes, otherwise there would be no requeuing. And, btw. the golden rule
of scheduling/shaping is limiting below "hardware" limits.

> Its quite possible that there simply might
> a subtle timing change that causes feedback through HTBs borrowing
> and ceiling.

I'd add my previous suspicion there could be not enough enqeuing on
time for the fastest class (could be also very bursty), so other
classes can borrow more.

>
> So what would really be useful to understand this is to make HTB
> control the queue and see if it behaves as expected.
>

Right, trying with lower rates/ceils should explain this.

Jarek P.
