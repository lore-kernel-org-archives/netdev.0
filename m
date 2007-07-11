From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ANNOUNCE] iproute2 2.6.22-070710
Date: Tue, 10 Jul 2007 19:01:03 -0700
Message-ID: <20070710190103.09ffa0e8@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, lartc@mailman.ds9a.nl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51622 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755360AbXGKCBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 22:01:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an update to iproute2 utilities including bug fixes and features
related to 2.6.22 kernel.

This package tries to be source compatible across releases.
The same source should build on older systems, but obviously the
newer kernel features won't be available.

It can be downloaded from:
  http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.22-070710.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

For more info on iproute2 see:
  http://linux-net.osdl.org/index.php/Iproute2

Changelog

David Lamparter (1):
      iproute2: Format IPv6 tunnels endpoints nicely.

Mike Frysinger (1):
      ip/routef lifesaver

Patrick McHardy (1):
      Fwd: Re: more iproute2 issues (not critical)

Pavel Roskin (1):
      ip: add support for displaying link types 802 and 803

Stephen Hemminger (11):
      Revert "Increase internal clock resolution to nsec"
      Add xt_tcpudp.h
      incorrect initialization
      headers update to 2.6.22
      fix last change
      fix build warnings
      netem: static
      Add TC_LIB_DIR environment variable.
      ss: fix issues with signed inodes

Thomas Graf (2):
      iproute2: support for goto/nop action and detached flag
      iproute2: Support IFF_LOWER_UP and IFF_DORMANT

Yasuyuki KOZAKAI (1):
      Fix symbolic link to tc-bfifo.8

jamal (2):
      SAD info
      SPD info



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
