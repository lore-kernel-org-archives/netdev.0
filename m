From: "Gianfranco Delli Carri" <gf.dellicarri@ncc.itgate.net>
Subject: Kernel 2.4.25 + VLAN + CBQ disc broken ?
Date: Tue, 23 Mar 2004 02:02:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4008E74134355D43998FFFC3D637BB030463DF@starsky.ncc.itgate.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Greetigs,

seems that in a 2.4.25 kernel, with VLAN configured, if you try tu use CBQ disc on VLAN subIf no more traffic can be passed. (NO ARP, NO IP)

Just after: 
/sbin/tc qdisc add dev eth1.10 root handle 1 cbq bandwidth 100Mbit avpkt 1000 cell 8

traffic was dropped.

Seems that in the same server enviroment the CBQ disc attached to the untagged interface can work without problems.

Thanks in advance for your help.

Regards,

Gianfranco
