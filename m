From: Stephen Hemminger <shemminger@osdl.org>
Subject: 2.6.12-rc6-tcp1
Date: Tue, 7 Jun 2005 14:23:09 -0700
Message-ID: <20050607142309.061a7ced@unknown-215.office.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@digeo.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

http://developer.osdl.org/shemminger/patches/2.6.12-rc6-tcp1

This is the update  of the TCP pluggable congestion framework with
other network changes (targeted for 2.6.13)

Minor tweaks from last time:
	* move tcpdiag_put to tcp.h to avoid build problems when IP_TCPDIAG is
	  a module.
	* sysctl tcp_congestion_control now checks for valid values
	* default tcp_congestion_control is determined LIFO (ie last one registered
	  is the default). Sysctl just reorders list
	+ added /sys/class/net/ethX/weight interface
	+ added scalable TCP
	- removed version patch to make integration with -mm easier

fastroute-stats-remove.patch
no-congestion.patch
no-throttle.patch
bigger-backlog.patch
fix-weightp.patch
weight-sysfs.patch
tcp_super_tso_v3.patch
tcp_infra.patch
tcp_bic.patch
tcp_westwood.patch
hstcp.patch
hybla.patch
vegas.patch
h-tcp.patch
scaleable_tcp.patch
