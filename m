From: David Miller <davem@davemloft.net>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Thu, 30 Apr 2009 04:05:35 -0700 (PDT)
Message-ID: <20090430.040535.247823152.davem@davemloft.net>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>
	<20090430.022417.07019547.davem@davemloft.net>
	<96ff3930904300351x60842bc1me0431c856f631773@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew@whydna.net, netdev@vger.kernel.org
To: jelaas@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39088
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753283AbZD3LFl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 07:05:41 -0400
In-Reply-To: <96ff3930904300351x60842bc1me0431c856f631773@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jens L=E5=E5s <jelaas@gmail.com>
Date: Thu, 30 Apr 2009 12:51:16 +0200

> The main problem though was that the mapping is randomized. We wanted
> to set smp_affinity correctly for tx to match rx. That was actually
> the main reason for our local hacks.

It's NOT RANDOMIZED, READ THE CODE!

It takes the RX queue number and uses it to select the TX
queue.

That anything but random!
