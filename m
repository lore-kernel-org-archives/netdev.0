From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Mon, 12 Jan 2009 21:45:50 -0800 (PST)
Message-ID: <20090112.214550.23199011.davem@davemloft.net>
References: <4967D36E.6020207@cosmosbay.com>
	<20090109225309.GC4819@1wt.eu>
	<4967DF10.2010107@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, ben@zeus.com, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37807
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752280AbZAMFpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 00:45:49 -0500
In-Reply-To: <4967DF10.2010107@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 10 Jan 2009 00:34:40 +0100

> David, do you think we still must call __tcp_splice_read() only once
> in tcp_splice_read() if SPLICE_F_NONBLOCK is set ?

Eric, I'll get to this thread as soon as I can, perhaps tomorrow.  I
want to get all of the build fallout and bug fixes for 2.6.29-rcX
sorted before everyone heads off to LCA in the next week or so :-)
