From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [Fwd: [Bug 1994] New: pinging endpoint through IPSec tunnel crashes
 target]
Date: Sun, 01 Feb 2004 10:30:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <401D45AD.8010105@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anyone?

thanks,
Nivedita

-------- Original Message --------
Subject: [Bug 1994] New: pinging endpoint through IPSec tunnel crashes target
Date: Sun, 1 Feb 2004 09:59:04 -0800
From: bugme-daemon@osdl.org
To: niv@us.ibm.com

http://bugme.osdl.org/show_bug.cgi?id=1994

            Summary: pinging endpoint through IPSec tunnel crashes target
     Kernel Version: 2.6.1
             Status: NEW
           Severity: blocking
              Owner: niv@us.ibm.com
          Submitter: casteyde.christian@free.fr


Distribution:
Slackware 9.1 + vanilla 2.6.1 kernel compiled from source + pppd 2.4.2

Hardware Environment:
K7 2GHz + ne2k Ethernet cards + ppp + pppoe + netfilter + ipv4 ipsec

Software Environment:
kame tools for ipsec, pppd 2.4.2 + pppoe plugin for Internet connection

Problem Description:
I tried to build an experimental IPSec tunnel with manual keying,
to forward traffic from dummy network of computer A to dummy network
of computer B, which are interconnected by a real network.

I therefore mount dummy0 on both computers (192.168.20.1 and 192.168.20.2),
activated IP forwarding on both, relax firewall rules, and set up
IPv4 IPSec tunnel between both computer to relay packets from 192.168.20.x
through my Internet connection.
My ipsec.conf file defines IPSec policy as shown :

spdadd 192.168.20.1 192.168.20.2 any -P out ipsec
         esp/tunnel/xx.yy.zzz.tt-uu.170.31.3/require
         ah/tunnel/xx.yy.zzz.tt-uu.170.31.3/require;

spdadd 192.168.20.2 192.168.20.1 any -P in ipsec
         esp/tunnel/xx.yy.zzz.tt-uu.170.31.3/require
         ah/tunnel/xx.yy.zzz.tt-uu.170.31.3/require;

(real IP adresses masked).

Then ping 192.168.20.1 crashes the pinged machine.
Oops not available (system freeze under X11).

Steps to reproduce:
Build an IPSec tunnel and ping the remote machine
as described upper.

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
