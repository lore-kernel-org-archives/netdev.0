From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Intel PRO/1000 NIC
Date: Mon, 15 Sep 2003 13:04:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010124F04A@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Lisong Xu" <lxu2@unity.ncsu.edu>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I am sending UDP data from one PC to another PC directly 
> through a cross cable. The NIC of sender is Intel(r) PRO/1000 
> MT Server Adapter, and the NIC of receiver is on-board Intel 
> PRO/1000 (Dell PowerEdge 1600SC).

A dump of lspci -vvv, ethtool -i eth<x>, and ethtool -d eth<x> will tell
us the 8254x controller version you're using; the driver version; if
you're running PCI or PCI-X, and at what speed; and what you're sharing
the bus with.

Ethtool version 1.8: http://sf.net/projects/gkernel.
Latest e1000: http://sf.net/projects/e1000.

-scott
