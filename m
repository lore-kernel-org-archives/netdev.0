From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/13]: netdev: Allocate multiple queues for TX.
Date: Wed, 16 Jul 2008 08:00:33 +0000
Message-ID: <20080716080033.GA4259@ff.dom.local>
References: <20080710.035610.167480342.davem@davemloft.net> <20080716070108.GA4099@ff.dom.local> <20080716.003700.193213605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:23000 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763AbYGPHzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 03:55:43 -0400
Received: by yw-out-2324.google.com with SMTP id 9so2702386ywe.1
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 00:55:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080716.003700.193213605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2008 at 12:37:00AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 16 Jul 2008 07:01:08 +0000
> 
> > I wonder if it was tested with lockdep? It seems additional
> > annotation is needed for such nesting (not counting rx_queue.lock
> > annotation).
> 
> I know, and I know about your patch wrt the queue lock
> initializations.

Fine... I don't think much about this particular patch. I try to read
this code, and... it's hard to guess what do you know, and plan to fix
yet. So it looks like it's better to wait for some official "finished"
sign...

Jarek P.
