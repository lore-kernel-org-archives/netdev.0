From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: umip-0.3 release
Date: Sun, 01 Apr 2007 11:46:38 +0900
Message-ID: <20070401114512.E3E8.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:48429 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbXDAC7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 22:59:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(sorry if you receive multiple copies of this notice)

Announcement of umip-0.3 release

The USAGI Project is pleased to announce the release of umip-0.3
which is a patch set for MIPL2 software suite and the latest Linux
kernel (2.6.21-rc5).  umip-0.3 can be downloaded from the following
location:

- Userland tarball:
ftp://ftp.linux-ipv6.org/pub/usagi/patch/mipv6/umip-0.3/daemon/tarball/mipv6-daemon-umip-0.3.tar.gz

- Userland patch set:
ftp://ftp.linux-ipv6.org/pub/usagi/patch/mipv6/umip-0.3/daemon/patch

- Kernel patch set:
ftp://ftp.linux-ipv6.org/pub/usagi/patch/mipv6/umip-0.3/kernel/patch/

The Helsinki University of Technology (HUT) Go-Core Project and the
USAGI Project have been developing MIPL2 cooperatively which is a
Mobile IPv6 (MIPv6) stack on Linux-2.6.  Since 2006, the USAGI
Project has been focusing on merging MIPv6 kernel patches into the
mainline kernel source tree and most of the patches have already
been integrated into the source tree.  However, there has been no
publicly available userland of MIPL2 which runs on the latest kernel.

umip-0.3 contains patches for both userland daemon (mip6d) and
kernel.  The userland patches are against the MIPL-2.0.2 source
codes and they are required mainly because there were some design
changes of the MIPv6 kernel patches during the merging process.
The userland patches will be sent to the HUT Go-Core Project members.
The kernel patches are against Linux kernel 2.6.21-rc5 and those
are required to make MIPv6-specific routing and XFRM policy management
work properly.  Some of the kernel patches are intended for the
mainline kernel, which will be sent to the Linux network community ML.
The other kernel patches are experimental and they are not intended
for the mainline kernel.

With the mip6d and kernel of umip-0.3, one can leverage MIPv6
protocol (MN/HA/CN) with or without IPsec configuration.  Although
the main features of MIPv6 have been confirmed to work as expected
with umip-0.3, there are some known issues and those can be found
at <http://www.linux-ipv6.org/memo/mipv6/>.



