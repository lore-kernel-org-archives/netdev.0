From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ircomm: release tty before sleeping potentially
 indefintely
Date: Sun, 03 Mar 2013 21:36:01 -0500 (EST)
Message-ID: <20130303.213601.1201168888595187293.davem@davemloft.net>
References: <1362355465.3221.82.camel@thor.lan>
	<20130303.193313.408641189137321065.davem@davemloft.net>
	<1362359178.3221.118.camel@thor.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, samuel@sortiz.org,
	gregkh@linuxfoundation.org, jslaby@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: peter@hurleysoftware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362359178.3221.118.camel@thor.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Hurley <peter@hurleysoftware.com>
Date: Sun, 03 Mar 2013 20:06:18 -0500

> But regardless, this function __cannot__ sleep holding the tty_lock().

So drop it across the schedule(), but recheck the termios after
regrabbing it.
