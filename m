From: Crutcher Dunnavant <crutcher@eng.ua.edu>
Subject: init_foodev cleanup questions
Date: Mon, 1 Jul 2002 23:54:18 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020701235418.B4148@monket.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hello all.

I've got some time on my hands, so I am walking through
all the network drivers, and cleaning up use of init_foodev.
This means zapping foo_setup, and kmallocing or memseting
dev->priv;

I'm doing this at the prompting of an entry on the
kernel-janitors TODO list.

Very much of this code is utter crap, and the fixes are
obvious.

However, I have some questions regarding the legacy probe
code from drivers/net/Space.c

can I safely remove bar_probe() from Space.c, if I also
cleanup bar.c so as to make it a module_init/module_exit
based module?

Oh, and something seems to be wrong with the listserver,
I'm getting the following error, and Sender: is not
getting set correctly.

	X-Authentication-Warning: oss.sgi.com: majordomo set sender to owner-netdev@oss.sgi.com using -f

-- 
Crutcher Dunnavant <crutcher+spam@eng.ua.edu>
ECSS System Hacker / UA COE CS Senior
