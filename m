From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Fix a connect() race with timewait sockets
Date: Wed, 02 Dec 2009 22:38:37 -0800 (PST)
Message-ID: <20091202.223837.203062830.davem@davemloft.net>
References: <4B152F97.1090409@gmail.com>
	<20091202.005937.177088443.davem@davemloft.net>
	<fd1a5ee40912020805r7a490ea2mdf7dc8597b9973b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kdakhane@gmail.com, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, zbr@ioremap.net
To: ashwas@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56330
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751020AbZLCGib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 01:38:31 -0500
In-Reply-To: <fd1a5ee40912020805r7a490ea2mdf7dc8597b9973b8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashwani Wason <ashwas@gmail.com>
Date: Wed, 2 Dec 2009 08:05:51 -0800

> Both reuse and recycle were enabled for this test. (I know because we,
> Kapil and I are working together on different aspects of this.)

Thanks, so the timewait recycling code paths really are relevant.
