From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3796] New: ipsec causes kernel deadlock
Date: Mon, 22 Nov 2004 11:59:35 -0800
Message-ID: <20041122115935.4d6f4e21.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bill@crowellsystems.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 22 Nov 2004 10:40:48 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3796] New: ipsec causes kernel deadlock


http://bugme.osdl.org/show_bug.cgi?id=3796

           Summary: ipsec causes kernel deadlock
    Kernel Version: 2.6.10-rc2
            Status: NEW
          Severity: blocking
             Owner: jgarzik@pobox.com
         Submitter: bill@crowellsystems.com


Distribution:slack/mfxlinux
Hardware Environment:i386
Software Environment:Openswan
Problem Description: when instantiating a gateway-network connection using
Openswan tools, the server at the 'gateway' end of the tunnel connection will
deadlock during the ISAKMP stage 1. The network-network tunnel is built
properly. Setting the boot parameter nmi_watchdog=1 does not produce any
debugging output on the console.

Steps to reproduce:
install Openswan. Build an ipsec.conf file with the 4 virtual tunnels that
comprise 1 server-server link. Set auto=add so that the connections may be
brought up manually. Instantiate ipsec. Manually ipsec auto --verbose --up
net-net, then ipsec auto --verbose --up gate-net. The machine on gate will deadlock.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
