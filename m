From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: nat bypass
Date: Mon, 28 Jun 2010 15:43:46 +0530
Message-ID: <AANLkTil_H1QeaCHQYhMjVRFiLwtqF9yLAJZ9BWecOIDW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Netfilter mailing list <netfilter@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

  A -------> R ------->S

I have a linux machine A is connected to Linux machine R . Machine R
is having two network interfaces and acting as a router .
It has a dhcp server running  . It will assign ip in 192.168.1.0/24
subnet to all machine connected on lan side ( A is connected also in
lan side ) . Wan side of R is connected to HTTP server S . There is
also a DHCP server running on S to assign ip in 10.232.18.0/24 subnet
.  Is there any way , in which NAT should be bypassed to get ip from
DHCP server running  on S . My question is : How can A will get  an ip
from 10.232.18.0/24 pool ip .?
ebtables is an option ? How can we make it ?
Is there any other optimal way ?


Thanks,
Ratheesh
