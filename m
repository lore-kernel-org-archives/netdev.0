From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Randomise invalid MAC addresses
Date: Tue, 24 Jan 2012 15:19:06 -0500 (EST)
Message-ID: <20120124.151906.1600710663231922646.davem@davemloft.net>
References: <20120124171546.GA32184@atrey.karlin.mff.cuni.cz>
	<20120124182826.GA24128@electric-eye.fr.zoreil.com>
	<1327430853.2568.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, pavel@ucw.cz, alan@lxorguk.ukuu.org.uk,
	torne@google.com, nic_swsd@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327430853.2568.4.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 24 Jan 2012 18:47:33 +0000

> None of the push-back from netdev is going to have any effect on the
> embedded system developers who are failing to program MAC addresses
> properly; it's only going to hurt those adventurous users.

The implementation of denying interface bringup until a valid MAC is
configured is actually helping these adventurous users if the embedded
guys (which in the Intel situation, was the case) put the hack into
userspace to set the MAC address before bringing the interface up.

And this is really the only solution I think is warranted.
