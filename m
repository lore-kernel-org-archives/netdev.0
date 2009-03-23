From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: fix BUG during net device "upping"
Date: Mon, 23 Mar 2009 01:05:41 -0700 (PDT)
Message-ID: <20090323.010541.94308473.davem@davemloft.net>
References: <20090322.212107.55546529.davem@davemloft.net>
	<20090323080455.GA4976@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, marcin.slusarz@gmail.com, netdev@vger.kernel.org,
	k-keiichi@bx.jp.nec.com, stable@kernel.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60253
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756309AbZCWIFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 04:05:54 -0400
In-Reply-To: <20090323080455.GA4976@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 23 Mar 2009 08:04:55 +0000

> What is the rationale of this decision? printk is a basic tool,
> especially designed to work in as many places as possible, and
> netconsole is rather something secondary (sorry Matt)?!

And this basic tool cannot work from the drivers ->open() method.
