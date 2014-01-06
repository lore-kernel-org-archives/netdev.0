From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hso: fix handling of modem port SERIAL_STATE
 notifications
Date: Mon, 06 Jan 2014 16:39:26 -0500 (EST)
Message-ID: <20140106.163926.1801604023600319341.davem@davemloft.net>
References: <1389024449.1866.3.camel@dcbw.local>
	<20140106.163036.1031013112322786.davem@davemloft.net>
	<1389044380.15419.4.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hns@goldelico.com, j.dumon@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	marek.belisko@gmail.com, e.verdonck@option.com
To: dcbw@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389044380.15419.4.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw@redhat.com>
Date: Mon, 06 Jan 2014 15:39:40 -0600

> If the driver ever gets to that callback for any !Modem port, something
> is horribly wrong, which the BUG_ON() was attempting to make explicit.
> The driver only enables that callback for the Modem port, so yeah, it's
> somewhat defensive.  I'm happy to send a fixup if you like?

You don't have to if you think the BUG_ON() is warranted.
