From: "Thompson, Ian" <Ian_Thompson@adaptec.com>
Subject: ARP problem?
Date: Wed, 16 Oct 2002 15:54:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E156A23F1885D4119ED800B0D0498A9F02128B94@aimexc07.adaptec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

I'm seeing some odd behavior in RedHat 7.3 when handling ARP packets.  I
have two Intel NIC cards, eth0 and eth1, in one machine, connected to the
same switch.  eth0 is set to IP0 and has MAC addr M0, and eth1 is at IP1 and
MAC M1.  Now, if another machine connected to the switch sends an ARP
broadcast asking who is at IP0, I see two replies on the wire -- IP0 is at
M0, and IP0 is at M1.  This result seems contradictory to me; could it be
some sort of feature that I'm not aware of?  If so, can I disable it?

I am trying to devlop some code to support an active failover case, so I
want two seperate devices on the same physical network.  I have seen the
same result even if IP0 and IP1 are on different subnets, or even if one is
a class A and the other is a class C address.  

I'm sorry if this has already been discussed -- I haven't seen much relating
to it in the archives.

TIA,
-ian

---
Ian Thompson               Firmware Engineer
Adaptec, Inc               Storage Networking Group
408.957.4909               408.957.6800 (fax)
ian_thompson@adaptec.com
