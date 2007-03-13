From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ANNOUNCE] iproute2 2.6.20-070313
Date: Tue, 13 Mar 2007 15:15:49 -0700
Message-ID: <20070313151549.332004c9@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38188 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933764AbXCMWPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 18:15:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an experimental to the iproute2 command set.

The version number includes the kernel version to denote what features are
supported. The same source should build on older systems, but obviously the
newer kernel features won't be available. As much as possible, this package
tries to be source compatible across releases.

It can be downloaded from:
  http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.20-070313.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

For more info on iproute2 see:
  http://linux-net.osdl.org/index.php/Iproute2

Changes:

Jamal Hadi Salim:
      update rest to use nl_mgrp
      nl_mgrp to crap if base multicast groups exceeded
      Old bug on tc

Mike Frysinger:
      do not ignore build failures in subdirs of iproute2

Noriaki TAKAMIYA:
      enabled to manipulate the flags of IFA_F_HOMEADDRESS or IFA_F_NODAD from ip.

Patrick McHardy:
      tbf: fix latency printing
      Use tc_calc_xmittime() where appropriate
      Introduce tc_calc_xmitsize and use where appropriate
      Introduce TIME_UNITS_PER_SEC to represent internal clock resolution
      Replace "usec" by "time" in function names
      Add sprint_ticks() function and use in CBQ
      Handle different kernel clock resolutions
      Increase internal clock resolution to nsec

Stephen Hemminger:
      netem use read/write for changes
      fix tc-pfifo and tc-bfifo man pages
      iptables library fix
      TC bfifo man page
      Use kernel headers from 2.6.20.y

Thomas Hisch:
      Fixes use of uninitialized string

