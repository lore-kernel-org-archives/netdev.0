From: Stephen Hemminger <shemminger@osdl.org>
Subject: 2.6.0-test7-netx2
Date: Fri, 10 Oct 2003 16:06:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010160611.2fba3cf7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, John Heffner <jheffner@psc.edu>,
        "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

http://developer.osdl.org/shemminger/netx/2.6/2.6.0-test7/2.6.0-test7-netx2/

This patch set contains experimental network protocols and drivers.

Changes since last installment:
+ bugfixes accepted are in linus.net
* TCP Vegas not a config option
+ more WAN driver cleanup
+ High Speed TCP patch 
+ New e100 driver (from Scott Feldman)
+ ISA TokenRing probing changes
+ VLAN using hlist and RCU

TCP includes two alternative congestion mechanism. Both are compiled
in, but not enabled.
    Vegas 			=> /proc/sys/net/tcp_vegas_cong_avoid
       got this from David Miller, but more info at
	  http://flophouse.com/~neal/uw/linux-vegas/

    Sally Floyd High Speed TCP  => /proc/sys/net/tcp_altAIMD
       see http://www.hep.ucl.ac.uk/~ytl/tcpip/hstcp/index.html

Auto tuning receive and send buffers is enabled by default
     via /proc/sys/net/tcp_rcvbuf_mode from John Heffner

There is also a new algorithm for sharing memory among lots of connections
also from John.

======================================================================
linus.net
netx.patch
#
# Bug fixes
#
hostess-retval.patch
synclink-retval.patch
probe-regression.patch
syncppp-if-ptr.patch
sealevel-if-ptr.patch
#
# ISA ethernet device probing
#
probe2.patch
de620-probe2.patch
ni65-probe2.patch
ni52-probe2.patch
ni5010-probe2.patch
sk16-probe2.patch
3c505-probe2.patch
3c507-probe2.patch
arlan-probe2.patch
wavelan-probe2.patch
3c501-probe2.patch
82596-probe2.patch
#
# ISA Tokenring device probing
#
probe2-tokenring.patch
smctr-probe2.patch
proteon-probe2.patch
#probe2-skisa.patch
#probe2-ibmtr.patch
#
# New devices
#
stir4200.patch
e100-3.0.6_dev.patch
#
# IRDA cleanups
#
hashbin-inlist.patch
hashbin-const.patch
hashbin-no-sorted.patch
hashbin-no-unused.patch
hashbin-hlist.patch
irda-usb.patch
#
# WAN device cleanup
#
sbni-request-region.patch
cosa-major.patch
cosa-name.patch
cosa-alloc-netdev.patch
hostess_sv11-nomodinc.patch
hostess_sv11-allocnetdev.patch
lmc-pci_ids.patch
lmc-nomodinc.patch
lmc-pcidev.patch
lmc-allocnetdev.patch
farsync-nomodinc.patch
pc300-nomodinc.patch
#
# Janitor cleanups
#
tms380tr-nomodstub.patch
wan-dev-get.patch
nfs-seq-file.patch
dev-alloc-deprecated.patch
vlan-hlist.patch
#
# TCP Enhancements
#
tcp-vegas.patch
tcp-hstcp.patch
tcp-auto-tune.patch
