From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] multiqueue changes
Date: Mon, 02 Nov 2009 03:35:33 -0800 (PST)
Message-ID: <20091102.033533.08766686.davem@davemloft.net>
References: <20091030100033.GA6150@ff.dom.local>
	<1257009952.9706.30.camel@HP1>
	<20091101132017.GA2598@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, kaber@trash.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55758
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754379AbZKBLfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 06:35:08 -0500
In-Reply-To: <20091101132017.GA2598@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 1 Nov 2009 14:20:17 +0100

> There is a question if we can predict in ->probe() MSI-X should be
> successfully enabled in ->ndo_open() for probed hardware. If so,
> then it could go e.g. like this:

We never can know this.

Another device driver can eat up all the MSI-X vectors in the PCI
domain before we make the request_irq() calls in ->open().
