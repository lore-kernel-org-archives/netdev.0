From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 2/2] pasemi_mac: Netpoll support
Date: Wed, 26 Mar 2008 10:08:28 -0500
Message-ID: <20080326150828.GA6728@lixom.net>
References: <20080326015625.GA23103@lixom.net> <20080326015801.GC23103@lixom.net> <47EA445D.9090509@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, linuxppc-dev@ozlabs.org,
	pasemi-linux@ozlabs.org, netdev@vger.kernel.org
To: Valentine Barshak <vbarshak@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:40562 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031AbYCZO76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 10:59:58 -0400
Content-Disposition: inline
In-Reply-To: <47EA445D.9090509@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2008 at 03:41:01PM +0300, Valentine Barshak wrote:
>> +	pasemi_mac_tx_intr(mac->tx->chan.irq, mac->tx);
>> +	enable_irq(mac->tx->chan.irq);
>> +
>> +	disable_irq(mac->rx->chan.irq);
>> +	pasemi_mac_rx_intr(mac->rx->chan.irq, dev);
>
> Shouldn't this actually be pasemi_mac_rx_intr(mac->rx->chan.irq, mac->rx)?

Yeah, it should. It used to take the netdev pointer instead. And the
void * argument means I never got a compiler warning from it.

Thanks!

-Olof

