From: Pekka Savola <pekkas@netcore.fi>
Subject: bugs in net/ipv6/mcast.c (fwd)
Date: Sat, 25 Oct 2003 22:27:27 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310252226470.12162-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ed Rupp <niteowl@austin.rr.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Probably fixed already, but just in case...

---------- Forwarded message ----------
Date: Sat, 25 Oct 2003 07:23:53 -0500
From: Ed Rupp <niteowl@austin.rr.com>
To: pekkas@netcore.fi
Subject: bugs in net/ipv6/mcast.c

Hi.  In the latest linux-2.6.0-test8 source there are 2 bugs in 
net/ipv6/mcast.c
In function inet6_mc_check() the if statements on lines 607 and 609 have
extra semicolons that will cause the code to fail.

                if (mc->sfmode == MCAST_INCLUDE && i >= psl->sl_count);
                        rv = 0;
                if (mc->sfmode == MCAST_EXCLUDE && i < psl->sl_count);
                        rv = 0;
