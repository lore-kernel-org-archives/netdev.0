From: Pavel Machek <pavel@ucw.cz>
Subject: ipw2100: firmware problem
Date: Wed, 8 Jun 2005 16:23:10 +0200
Message-ID: <20050608142310.GA2339@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Netdev list <netdev@oss.sgi.com>,
        kernel list <linux-kernel@vger.kernel.org>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

I'm fighting with firmware problem: if ipw2100 is compiled into
kernel, it is loaded while kernel boots and firmware loader is not yet
available. That leads to uninitialized (=> useless) adapter.

What's the prefered way to solve this one? Only load firmware when
user does ifconfig eth1 up? [It is wifi, it looks like it would be
better to start firmware sooner so that it can associate to the
AP...].

Last initcall available in kernel is late_initcall; that's not late
enough for me. Is adding one more initcall that is started when
userland is available a solution?
								Pavel
