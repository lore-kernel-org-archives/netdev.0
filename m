From: David Miller <davem@davemloft.net>
Subject: Re: splice from half-closed socket returning -EAGAIN
Date: Mon, 05 Jan 2009 00:52:49 -0800 (PST)
Message-ID: <20090105.005249.193722431.davem@davemloft.net>
References: <20090105081136.GA4460@ff.dom.local>
	<20090105.001401.63730458.davem@davemloft.net>
	<20090105082252.GB4460@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, jens.axboe@oracle.com, ben@zeus.com,
	opurdila@ixiacom.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43432
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751570AbZAEIwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 03:52:49 -0500
In-Reply-To: <20090105082252.GB4460@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 5 Jan 2009 08:22:52 +0000

> On Mon, Jan 05, 2009 at 12:14:01AM -0800, David Miller wrote:
> > Is it really the same condition in the end?
> 
> Yes!?

Indeed, as you explained in your follow-up, this splice
non-block flag is used to compute the socket timeout value
and thus it is in fact totally unnecessary.

I'll toss these checks in the net-2.6 tree, thanks!
