From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ircomm: release tty before sleeping potentially
 indefintely
Date: Sun, 03 Mar 2013 19:33:13 -0500 (EST)
Message-ID: <20130303.193313.408641189137321065.davem@davemloft.net>
References: <1362350153-26225-1-git-send-email-sasha.levin@oracle.com>
	<20130303.174739.1195645942179862011.davem@davemloft.net>
	<1362355465.3221.82.camel@thor.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, samuel@sortiz.org,
	gregkh@linuxfoundation.org, jslaby@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: peter@hurleysoftware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362355465.3221.82.camel@thor.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Hurley <peter@hurleysoftware.com>
Date: Sun, 03 Mar 2013 19:04:25 -0500

> All these are re-tested in the loop. What state test isn't repeated?

One that rechecks the non-blocking filp flag, the
TTY_IO_ERROR tty flag and the termios settings.

Like I said, all of the state tests performed at the beginning of
this function, before enterring the loop.
