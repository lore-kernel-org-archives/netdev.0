From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: sunhme stopped working somewhere in 2.6.0-test4
Date: Sat, 6 Sep 2003 21:31:51 -0700
Sender: sparclinux-owner@vger.kernel.org
Message-ID: <20030907043151.GB33595@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <sparclinux-owner@vger.kernel.org>
To: sparclinux@vger.kernel.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

I had been running 2.6.0-test4 on my Ultra 10 for the last week without
problems.  Tonight I tried upgrading it to 2.6.0-test4-bk8 (which works
fine on my i386 test box) and the builtin sunhme card no longer functions.
When you try to do a "ifconfig eth0 up" I get the following on this console...

  happy meal: Aieee, transceiver MIF write bolixed
  happy meal: Aieee, transceiver MIF read bolixed

...and the operation fails.  It looks like there's been a number of changes
to sunhme in the last week (ethtool stuff, maybe some other things).... does
anyone have a hunch what I should try to change (or has this already been
fixed in BK perhaps?)

-Mitch
