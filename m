From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3992] New: Bondig. Not correct work function
 ARP Monitoring. Broken link.
Date: Wed, 5 Jan 2005 13:35:25 -0800
Message-ID: <20050105133525.2bab2e09.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 5 Jan 2005 07:59:17 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3992] New: Bondig. Not correct work function AR=
P Monitoring. Broken link.


http://bugme.osdl.org/show_bug.cgi?id=3D3992

           Summary: Bondig. Not correct work function ARP Monitoring. Bro=
ken
                    link.
    Kernel Version: 2.6.10
            Status: NEW
          Severity: normal
             Owner: jgarzik@pobox.com
         Submitter: stanislav@muhachev.petro.ru


Distribution:
Hardware Environment:
Vmware GSX machine
Software Environment:
Gentoo
Problem Description:
bonding interface going down and down slave link


Steps to reproduce:

2 virtual pc
identical gentoo linux (copy)
1 nic for both virtual pc
up 2 openvpn link trouch nic to another virtual pc (tap0 and tap1)[ethern=
et=20
bridge]
link both vpn1 and vpn2 - ok!(independing link like:192.168.1.1-192.168.1=
.2=20
and 192.168.2.1-192.168.2.2)

bonding vpn1 & vpn2 =F2=EE bond0 (bonding default setup -> nothing failov=
er=20
setings)
link =EE=EA!(192.168.100.1-192.168.100.2)

setting arp monitor in bonding (TUN/TAP driver not support Mii status)
link down!

arp request go from bond0(machine1)[from tap0 & tap1] to bond0(machine2) =
- ok.
arp answer bond0(machine2) interface - ok!
!!! bond0(machine2) -> tap0(tap1)(machine2) - noting!!!(arp answer broken=
)
resultat arp request not complite

situation analog both side

for monitoring use TCPDUMP

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
