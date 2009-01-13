From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 13 Jan 2009 15:27:59 -0800 (PST)
Message-ID: <20090113.152759.29875009.davem@davemloft.net>
References: <4966F2F4.9080901@cosmosbay.com>
	<20090109070415.GA27758@1wt.eu>
	<4966FC89.8040006@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, ben@zeus.com, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46676
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755798AbZAMX16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 18:27:58 -0500
In-Reply-To: <4966FC89.8040006@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 09 Jan 2009 08:28:09 +0100

> If the application uses setsockopt(sock, SOL_SOCKET, SO_RCVLOWAT,
> [32768], 4), it would be good if kernel was smart enough and could
> reduce number of wakeups.

Right, and as I pointed out in previous replies the problem is
that splice() receive in TCP doesn't check the low water mark
at all.
