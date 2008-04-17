From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 v2.6.25
Date: Thu, 17 Apr 2008 10:38:58 -0700
Message-ID: <20080417103858.0075236b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:51881 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756420AbYDQRjE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 13:39:04 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 1C4844F8030
	for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 10:39:03 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8Ap2b6yb+1ts for <netdev@vger.kernel.org>;
	Thu, 17 Apr 2008 10:39:00 -0700 (PDT)
Received: from extreme (97-115-70-231.ptld.qwest.net [97.115.70.231])
	by mail.vyatta.com (Postfix) with ESMTP id 8EFC54F8051
	for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 10:39:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New version of iproute2 utilities that includes bug fixes and
support for all the new features in kernel 2.6.25.

Source: (note old developer.osdl.org address works as well)
	http://devresources.linux-foundation.org/dev/iproute2/download/iproute=
2-2.6.25.tar.bz2

Git tree:
	git://git.kernel.org/pub/scm/network/iproute2/iproute2.git

Changelog:

Andreas Henriksson (3):
      iproute2: revert syntax help text mistake.
      iproute2: add synonyms for ip rule options to ip(8) manpage.
      iproute2: fix ip manpage typo (syntax error)

Bj=C3=B6rn Steinbrink (1):
      ss: Fix return value checks for net_*_open

Jesper Dangaard Brouer (7):
      In police, fix uninitialized "overhead" variable.
      TBF overhead parameter parsing.
      CBQ use matches() function instead of strcmp().
      CBQ, implement overhead parameter parsing.
      CBQ, doc usage of overhead parameter.
      police, implement overhead parameter parsing.
      ATM cell alignment.

Marcela Maslanova (2):
      I found out when I was writing manual page, that options ALGO_NAM=
E and
      man ip.8 miss xfrm option

Mike Frysinger (1):
      Do not strip binaries with `install`

PJ Waskiewicz (1):
      Update various classifiers' help output for expected CLASSID synt=
ax

Patrick McHardy (4):
      Add support for SFQ xstats
      Add flow classifier support
      cls_flow: add vlan-tag support
      Fix classifier help

Stephen Hemminger (33):
      Merge header file changes from net-2.6.25
      Fix breakage from netfilter/ip_tables header change.
      rlim qdisc support
      netem potential dist table overflow
      Update header files from net-2.6.25
      Revert "TC action parsing bug fix"
      fix typo in ip batch error message
      vlan meta tag match
      libnetlink: don't spin forever on receive error
      remove extra newline from perror() calls
      poll for errors after rtnl_send
      whitespace typo in tc_common.h
      fix problem caused by rtnl_send checks
      harmonize headers with upcoming 2.6.25
      Change where vlan option shows up in help
      ignore emacs backup files
      fix typos in help message for meta match
      reharmonize headers with pre-freeze 2.6.25
      add support for matching AOE and CAN ether types
      Protocol field on tc_filter is required
      minor typo fixes
      add include/linux/hdlc/ioctl.h
      Revert "rlim qdisc support"
      break excessively long lines
      get rid of warning from misnamed prototype
      decode the output of u32 matches
      missing dport in f_u32 output
      Add default value to /etc/iproute2/rt_dsfield
      revert earlier mistake ALGO_NAME is okay
      Update address of FSF in license
      IP link state show enhancements
      Update kernel headers to 2.6.25-rc7
      Update version

Templin, Fred L (1):
      iproute2-2.6.23: RFC4214 Support (v2.5)

Varun Chandramohan (1):
      Add missing prefix bit length for addrlabel

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E (3):
      Add addrlabel sub-command.
      Add more aliases for tunnel subcommand.
      Add missing description about ISATAP and IPv6 tunnels in ip(8) ma=
npage.

