From: John Wong <kernel@implode.net>
Subject: forcedeth and kernel 2.6.5 has "no link"
Date: Fri, 16 Apr 2004 11:38:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416183844.GA2923@gambit.implode.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: c-d.hailfinger.kernel.2004@gmx.net, manfred@colorfullife.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Under kernel 2.6.4, ethtool reports:

Settings for eth0:
        Link detected: yes

This is with forcedeth 0.23

Under kernel 2.6.5, ethtool reports:

Settings for eth0:
        Supports Wake-on: g
        Wake-on: d
        Link detected: no

This is with forcedeth 0.25

With 2.6.5, it doesn't see an link but there is one.  The connection is
quite slow, so I'm thinking it may be using 10baseT-HD instead of
100baseTx-FD.  The forcedeth driver does not appear to support
autonegotiation.

http://bugzilla.kernel.org/buglist.cgi?bug_status=UNCONFIRMED&bug_status=NEW&bug_status=OPEN&bug_status=ASSIGNED&bug_status=REOPENED&field0-0-0=product&type0-0-0=substring&value0-0-0=forcedeth&field0-0-1=component&type0-0-1=substring&value0-0-1=forcedeth&field0-0-2=short_desc&type0-0-2=substring&value0-0-2=forcedeth&field0-0-3=status_whiteboard&type0-0-3=substring&value0-0-3=forcedeth

I had submitted the bugzilla id 2283.  2496 is something that I am
experiencing too.

John
