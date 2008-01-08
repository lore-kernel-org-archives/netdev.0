From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ANNOUNCE] iproute2-2.6.24-rc7
Date: Tue, 8 Jan 2008 09:12:22 -0800
Message-ID: <20080108091222.514e976e@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53705 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755716AbYAHROe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 12:14:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a preliminary release that includes all the changes for new
features in 2.6.24.  It should be backward compatible with older kernel=
s.

   http://devresources.linux-foundation.org/dev/iproute2/download/iprou=
te2-2.6.24-rc7.tar.bz2

Note: This release is for validation (don't put it in your distros), th=
erefore
I didn't bother signing it.

Changelog since v2.6.23 release (edited).

Alexander Wirt (2):
      Fix various typos and nitpicks
      Add parameters to usage help text.

Andreas Barth (1):
      Remove bogus reference to tc-filters(8) from tc(8) manpage.

Andreas Henriksson (4):
      Fix corruption when using batch files with comments and broken li=
nes.
      iproute2: support dotted-quad netmask notation.
      iproute2: revert syntax help text mistake.
      iproute2: add synonyms for ip rule options to ip(8) manpage.

Denys Fedoryshchenko (1):
      iptables compatiablity

=46ran=C3=A7ois Delawarde (1):
      tc mask patch

Herbert Xu:
      Fix typo in tunnel code (o_key vs. i_key).
      Add NAT action

Jesper Dangaard Brouer (3):
      Overhead calculation is now done in the kernel.
      Cleanup: tc_calc_rtable().
      Change the rate table calc of transmit cost to use upper bound va=
lue.

Patrick McHardy (1):
      iproute 2.6.23 incompatibility

Pavel Emelyanov (1):
      iplink_parse() routine

Stephen Hemminger
      2.6.24-rc3 headers
      Fix off by one in nested attribute management.
      Fix dotted quad for bit order
      veth: use kernel header file
      snapshot target for makefile
      veth.h move to linux/
      Manual page fixes
      add decode of match rules
      Use netinet/tcp.h (with correction) rather than kernel headers
      add include/netinet/tcp.h
      Revert "TC action parsing bug fix"

Tomas Janousek (1):
      Correct documentation regarding PROMISC and ALLMULTI.

Vitaliy Gusev (2):
      Fix lost export-dynamic
      veth device link management

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E (1):
      rto_min value display overflow

