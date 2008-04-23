From: David Miller <davem@davemloft.net>
Subject: Re: LRO/GSO interaction when packets are forwarded
Date: Wed, 23 Apr 2008 03:42:25 -0700 (PDT)
Message-ID: <20080423.034225.176998769.davem@davemloft.net>
References: <20080423061538.GB3946@ff.dom.local>
	<20080423100702.GS21637@solarflare.com>
	<20080423103809.GB3994@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, stephen.hemminger@vyatta.com,
	kmansley@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45138
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754609AbYDWKmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 06:42:23 -0400
In-Reply-To: <20080423103809.GB3994@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 23 Apr 2008 10:38:10 +0000

> Thanks for explanation! I'd still like to know why it's wrong, and
> why we should turn this off on a device with ip_forwarding enabled
> without checking how smart this hardware is?

It's not about how smart the hardware is.

This a stateless feature, the device accumulates data into
large receive frames when it's TCP and the ports and addresses
match.

There is no knowledge of routes or anything like that, nor should
there be, because otherwise it would cease to be stateless.
