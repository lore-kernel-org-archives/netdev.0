From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [Bugme-new] [Bug 3992] New: Bondig. Not correct work function ARP Monitoring. Broken link.
Date: Thu, 6 Jan 2005 09:04:15 -0800
Message-ID: <F3EE2A9EB4576F40AFE238EC0AC04BC504716A1E@orsmsx402.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Andrew Morton" <akpm@osdl.org>, <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Our test lab has found a number of issues with ARP monitoring.  These bug=
s were on my to-do list for Q4 but got bumped due to other issues.  So no=
w they're on my to-do list for Q1.

That being said, if somebody else really wants to fix this before I get t=
o it, I won't complain.

-Mitch Williams=20

-----Original Message-----
From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On Beh=
alf Of Andrew Morton
Sent: Wednesday, January 05, 2005 1:35 PM
To: netdev@oss.sgi.com
Subject: Fw: [Bugme-new] [Bug 3992] New: Bondig. Not correct work functio=
n ARP Monitoring. Broken link.



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
