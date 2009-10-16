From: Joe Perches <joe@perches.com>
Subject: MAINTAINERS drivers/net cleanups?
Date: Fri, 16 Oct 2009 14:52:15 -0700
Message-ID: <1255729936.2267.179.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2229 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751782AbZJPVwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 17:52:12 -0400
Received: from [192.168.1.151] (Joe-Laptop.home [192.168.1.151])
	by mail.perches.com (Postfix) with ESMTP id 4845B24368
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 14:52:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings suggested adding a facility to
scripts/get_maintainer.pl to print the role of
each maintainer.  I added a bit more to print
statistics about the maintainers and "-by:" lines
from each git commit as well.

To see if it worked, I tested this script on
drivers/net:

$ for file in drivers/net/*.c ; do \
echo ; \
echo "------> $file" ; \
echo ; \
./scripts/get_maintainer.pl \
--git-since=5-years-ago \
--git-min-percent=0 -f --rolestats \
$file ; \
done

There are many people described as MAINTAINERS for
these files that have not had a single sign-off or
commit in git history.

That's 4+ years.

Here are the files, nominal maintainers, and the
sections of MAINTAINERS that could be dropped.

Should these individuals be removed from MAINTAINERS
and added to CREDITS if not already there?

------> drivers/net/3c505.c
------> drivers/net/eexpress.c
Philip Blundell <philb@gnu.org> (maintainer)

3C505 NETWORK DRIVER
M: Philip Blundell <philb@gnu.org>
L: netdev@vger.kernel.org
S: Maintained
F: drivers/net/3c505*

ETHEREXPRESS-16 NETWORK DRIVER
M: Philip Blundell <philb@gnu.org>
L: netdev@vger.kernel.org
S: Maintained
F: drivers/net/eexpress.*

------> drivers/net/8390.c
------> drivers/net/8390p.c
------> drivers/net/ax88796.c
------> drivers/net/lib8390.c
------> drivers/net/mac8390.c
------> drivers/net/zorro8390.c
Paul Gortmaker <p_gortmaker@yahoo.com> (maintainer)

8390 NETWORK DRIVERS [WD80x3/SMC-ELITE, SMC-ULTRA, NE2000, 3C503, etc.]
M: Paul Gortmaker <p_gortmaker@yahoo.com>
L: netdev@vger.kernel.org
S: Maintained
F: drivers/net/*8390*
F: drivers/net/ax88796.c

------> drivers/net/acenic.c
Jes Sorensen <jes@trained-monkey.org> (maintainer)

ACENIC DRIVER
M: Jes Sorensen <jes@trained-monkey.org>
L: linux-acenic@sunsite.dk
S: Maintained
F: drivers/net/acenic*

------> drivers/net/b44.c
Gary Zambrano <zambrano@broadcom.com> (maintainer)

BROADCOM B44 10/100 ETHERNET DRIVER
M: Gary Zambrano <zambrano@broadcom.com>
L: netdev@vger.kernel.org
S: Supported
F: drivers/net/b44.*

------> drivers/net/eth16i.c
Mika Kuoppala <miku@iki.fi> (maintainer)

ETHERTEAM 16I DRIVER
M: Mika Kuoppala <miku@iki.fi>
S: Maintained
F: drivers/net/eth16i.c

------> drivers/net/hp100.c
Jaroslav Kysela <perex@perex.cz> (maintainer)

HP100: Driver for HP 10/100 Mbit/s Voice Grade Network Adapter Series
M: Jaroslav Kysela <perex@perex.cz>
S: Maintained
F: drivers/net/hp100.*

------> drivers/net/ipg.c
Francois Romieu <romieu@fr.zoreil.com> (maintainer)
Sorbica Shieh <sorbica@icplus.com.tw> (maintainer)
Jesse Huang <jesse@icplus.com.tw> (maintainer)

IP1000A 10/100/1000 GIGABIT ETHERNET DRIVER
M: Francois Romieu <romieu@fr.zoreil.com>
M: Sorbica Shieh <sorbica@icplus.com.tw>
M: Jesse Huang <jesse@icplus.com.tw>
L: netdev@vger.kernel.org
S: Maintained
F: drivers/net/ipg.c

------> drivers/net/macb.c
Haavard Skinnemoen <hskinnemoen@atmel.com> (maintainer)

ATMEL MACB ETHERNET DRIVER
M: Haavard Skinnemoen <hskinnemoen@atmel.com>
S: Supported
F: drivers/net/macb.*

------> drivers/net/natsemi.c
Tim Hockin <thockin@hockin.org> (maintainer)

NATSEMI ETHERNET DRIVER (DP8381x)
M: Tim Hockin <thockin@hockin.org>
S: Maintained
F: drivers/net/natsemi.c

------> drivers/net/ni5010.c
Jan-Pascal van Best <janpascal@vanbest.org> (maintainer)
Andreas Mohr <andi@lisas.de> (maintainer)

NI5010 NETWORK DRIVER
M: Jan-Pascal van Best <janpascal@vanbest.org>
M: Andreas Mohr <andi@lisas.de>
L: netdev@vger.kernel.org
S: Maintained
F: drivers/net/ni5010.*

------> drivers/net/pppoe.c
------> drivers/net/pppox.c
Michal Ostrowski <mostrows@earthlink.net> (maintainer)

PPP OVER ETHERNET
M: Michal Ostrowski <mostrows@earthlink.net>
S: Maintained
F: drivers/net/pppoe.c
F: drivers/net/pppox.c

------> drivers/net/skge.c
------> drivers/net/sky2.c
Stephen Hemminger <shemminger@linux-foundation.org> (maintainer)

SKGE, SKY2 10/100/1000 GIGABIT ETHERNET DRIVERS
M: Stephen Hemminger <shemminger@linux-foundation.org>
L: netdev@vger.kernel.org
S: Maintained
F: drivers/net/skge.*
F: drivers/net/sky2.*

------> drivers/net/sonic.c
Thomas Bogendoerfer <tsbogend@alpha.franken.de> (maintainer)

SONIC NETWORK DRIVER
M: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
L: netdev@vger.kernel.org
S: Maintained
F: drivers/net/sonic.*

------> drivers/net/spider_net.c
------> drivers/net/spider_net_ethtool.c
Ishizaki Kou <kou.ishizaki@toshiba.co.jp> (maintainer)
Jens Osterkamp <jens@de.ibm.com> (maintainer)

SPIDERNET NETWORK DRIVER for CELL
M: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
M: Jens Osterkamp <jens@de.ibm.com>
L: netdev@vger.kernel.org
S: Supported
F: Documentation/networking/spider_net.txt
F: drivers/net/spider_net*

------> drivers/net/starfire.c
Ion Badulescu <ionut@badula.org> (maintainer)

STARFIRE/DURALAN NETWORK DRIVER
M: Ion Badulescu <ionut@badula.org>
S: Odd Fixes
F: drivers/net/starfire*

------> drivers/net/tehuti.c
Alexander Indenbaum <baum@tehutinetworks.net> (maintainer)
Andy Gospodarek <andy@greyhouse.net> (maintainer)

TEHUTI ETHERNET DRIVER
M: Alexander Indenbaum <baum@tehutinetworks.net>
M: Andy Gospodarek <andy@greyhouse.net>
L: netdev@vger.kernel.org
S: Supported
F: drivers/net/tehuti*

------> drivers/net/tlan.c
Samuel Chessman <chessman@tux.org> (maintainer)

TLAN NETWORK DRIVER
M: Samuel Chessman <chessman@tux.org>
L: tlan-devel@lists.sourceforge.net (subscribers-only)
W: http://sourceforge.net/projects/tlan/
S: Maintained
F: Documentation/networking/tlan.txt
F: drivers/net/tlan.*

------> drivers/net/typhoon.c
David Dillow <dave@thedillows.org> (maintainer)

3CR990 NETWORK DRIVER
M: David Dillow <dave@thedillows.org>
L: netdev@vger.kernel.org
S: Maintained
F: drivers/net/typhoon*



