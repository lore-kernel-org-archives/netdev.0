From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: eSwitch management
Date: Thu, 22 Apr 2010 16:16:32 -0700
Message-ID: <0B579583-F3D8-4C64-A844-34D69C1760D6@qlogic.com>
References: <C7F60C62.2AC93%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Scott Feldman <scofeldm@cisco.com>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:7968 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617Ab0DVXQe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 19:16:34 -0400
In-Reply-To: <C7F60C62.2AC93%scofeldm@cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I am following the discussions on iovnl patch closely. While it is going to take some time for iovnl patch to be reviewed and accepted, what would be the interim approach to manage the eswitch in NIC? We need to add support in qlcnic driver to configure the eswitch in our 10G NIC. Some of the things that we need to set to the switch are setting a port's VLAN, tx bandwidth etc. We would like to set these parameters for a bunch of ports at the start of the day and set it to the eswitch.
Can we expose sysfs nodes to manage the eswitch or should we have a netlink/ioctl support put in the driver?  Not sure if we can do it via sysfs in a clean way. Netlink seems to be the ideal candidate for this.  What is an acceptable solution? Any suggesstion, advice will be highly appreciated.

thanks much,
Anirban Chakraborty
 