From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2 2.6.11-050330
Date: Fri, 1 Apr 2005 12:07:27 -0800
Message-ID: <20050401120727.62700e8c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: lartc@mailman.ds9a.nl, linux-kernel@vger.kernel.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

An updated version of the iproute2 utilities is available at:
http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.11-050330.tar.gz

It supports the latest features from 2.6, but is backwards compatiable
with 2.4.

This update includes several bugfixes and build clean from
the previous version (2.6.11-050314):

[Jamal Hadi Salim]
	* Proper verison of iptables headers (from 1.3.1)
	* Set revision file in m_ipt
	* Fix action_util naming in mirred
	* don't call ll_init_map in mirred

[Thomas Graf]

	* Warn about wildcard deletions and provide IFA_ADDRESS upon
	  deletions to enforce prefix length validation for IPv4.
	* Fix netlink message alignment when the last routing attribute added
	  has a data length not aligned to RTA_ALIGNTO.
	
[Masahide NAKAMURA]
	
	* ipv6 xfrm allocspi and monitor support.
	
[Stephen Hemminger]
	* include/linux/netfilter_ipv4/ip_tables.h dont include compiler.h
	  because it isn't needed and not on all systems
	* Update rtnetlink.h and pkt_cls.h to be stripped versions
	  of headers from 2.6.12-rc1
	* switch to stack for netem tables
	* add -force option to batch mode
	* handle midline comments in batch mode
	* sum per cpu fields in lnstat correctly
