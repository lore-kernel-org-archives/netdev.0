From: Jim Castleberry <cjn@cypress.com>
Subject: macsonic.c SONIC driver
Date: Fri, 26 Apr 2002 14:08:43 -0600
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3CC9B3CB.83C7753E@cypress.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
List-Id: netdev.vger.kernel.org

I have a need for the macsonic.c driver on an old Mac PPC machine but
it looks like the code has been broken for a long time.  I'm trying to
figure out how it got broken and who might know more about it.

Poking around in the CVS logs it looks like the damage happened around
January, 2000.  About 400 of the 600 lines of macsonic.c changed,
including a change from including "macsonic.h" to including "sonic.h".
But the new code references a structure member sonic_local.sonic_desc,
and as far as I can tell the struct sonic_local defined in sonic.h has
never contained such a thing.  And macsonic.h doesn't exist any more.
So to make a long story short, macsonic.c won't compile.

Who knows more about this driver, how it got broken, and/or the easiest
way to fix it?

Thanks,

Jim
