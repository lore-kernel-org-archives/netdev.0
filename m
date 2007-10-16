From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ANNOUNCE] iproute2-2.6.23
Date: Tue, 16 Oct 2007 16:44:39 -0700
Message-ID: <20071016164439.3f8a4f00@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45743 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751754AbXJPXos convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 19:44:48 -0400
Received: from freepuppy.rosehill (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l9GNik3U004756
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 16:44:47 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that 2.6.23 is out, and the patch storm has settled
here is a new version of iproute2

http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.23.bz2

Changes since last version (v2.6.19)

Alexander Wirt (1):
      Drop bogus reference to tc-filters and add lartc.org link to manp=
age.

Andreas Barth (1):
      Remove bogus reference to tc-filters(8) from tc(8) manpage.

Andreas Henriksson (4):
      Add new rtacct/nstat manpages and additional symlinks.
      Fix overflow in time2tick / tick2time.
      Switch helpers tc_core_{time2ktime,ktime2time} from long to unsig=
ned as well.
      Also do tc_core_time2big argument (long->unsigned).

David Lamparter (1):
      iproute2: Format IPv6 tunnels endpoints nicely.

Eric Dumazet (1):
      lnstat : force a flush before sleep

Johannes Berg (1):
      show multicast groups

Lionel Elie Mamane (1):
      Fix ematch cmp and nbyte syntax help text.

Masahide NAKAMURA (3):
      ip: xfrm: Clean-up for internal mask to filter.
      ip: xfrm: Fix policy and state flags.
      ip: xfrm: Fix flush message.

Mike Frysinger (2):
      do not ignore build failures in subdirs of iproute2
      ip/routef lifesaver

Noriaki TAKAMIYA (1):
      enabled to manipulate the flags of IFA_F_HOMEADDRESS or IFA_F_NOD=
AD from ip.

PJ Waskiewicz (1):
      iproute2: sch_rr support in tc

Patrick McHardy (17):
      tbf: fix latency printing
      Use tc_calc_xmittime() where appropriate
      Introduce tc_calc_xmitsize and use where appropriate
      Introduce TIME_UNITS_PER_SEC to represent internal clock resoluti=
on
      Replace "usec" by "time" in function names
      Add sprint_ticks() function and use in CBQ
      Handle different kernel clock resolutions
      Increase internal clock resolution to nsec
      [Fwd: Re: more iproute2 issues (not critical)]
      TC action parsing bug fix
      Bug fix tc action drop
      IPROUTE2: RTNETLINK nested attributes
      Use FRA_* attributes for routing rules
      iplink: use netlink for link configuration
      Fix meta ematch usage of 0 values
      vlan support
      Prevent renaming interfaces to empty string.

Pavel Emelianov (2):
      Make ip utility veth driver aware
      Module for ip utility to support veth device (v.2.1)

Pavel Roskin (1):
      ip: add support for displaying link types 802 and 803

Rick Jones (1):
      rto support for ip command

Sridhar Samudrala (1):
      Fix bug  in display of ipv6 cloned/cached routes

Stephen Hemminger (33):
      netem parameters to change command
      fix tc-pfifo and tc-bfifo man pages
      iptables library fix
      TC bfifo man page
      Use kernel headers from 2.6.20.y
      Iproute2 v2.6.20-070313
      Revert "Increase internal clock resolution to nsec"
      Add xt_tcpudp.h
      incorrect initialization
      headers update to 2.6.22
      fix last change
      fix build warnings
      netem: static
      Add TC_LIB_DIR environment variable.
      Snapshot update for 2.6.22
      ss: fix issues with signed inodes
      v2.6.22-070710
      Fix ss to handle partial records.
      sanitized headers update to 2.6.23-rc3
      Fix m_ipt build
      Revert "Make ip utility veth driver aware"
      Fix modes of test files
      Update kernel headers to 2.6.23-rc5
      2.6.23 kernel headers
      Merge 192.168.0.5:src/iproute2
      don't make veth a shared library
      remove outdated netbug script.
      remove support for IP multipath
      don't allow "" for device name
      Revert "Remove bogus reference to tc-filters(8) from tc(8) manpag=
e."
      Revert "don't allow "" for device name"
      Update snapshot for release
      add q_rr to tc Makefile

Thomas Graf (2):
      iproute2: support for goto/nop action and detached flag
      iproute2: Support IFF_LOWER_UP and IFF_DORMANT

Thomas Hisch (1):
      Fixes use of uninitialized string

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E (1):
      IPROUTE2: Support IPv4/IPv6 Tunnel

Yasuyuki KOZAKAI (1):
      Fix symbolic link to tc-bfifo.8

jamal (5):
      update rest to use nl_mgrp
      nl_mgrp to crap if base multicast groups exceeded
      Old bug on tc
      see SAD info
      see SPD info

