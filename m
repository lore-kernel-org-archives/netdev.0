From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 v2.6.26
Date: Fri, 25 Jul 2008 14:10:54 -0700
Message-ID: <20080725141054.7e814236@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57406 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507AbYGYVK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 17:10:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New version of iproute2 utilities that includes bug fixes and
support for all the new features in kernel 2.6.26.

Source: (note old developer.osdl.org address works as well)
	http://devresources.linux-foundation.org/dev/iproute2/download/iproute2-2.6.26.tar.bz2

Git tree:
	git://git.kernel.org/pub/scm/network/iproute2/iproute2.git

Changelog:

Andreas Henriksson (3):
      Fix typos (syntax error) in ip(8) manpage.
      document promote_secondaries
      Add routel and routef man page.

Benjamin Thery (1):
      iproute2: add support for IFLA_NET_NS_PID in ip link

Bertrand Jacquin (1):
      netem: fix cross-compiling failure

Daniel Silverstone (1):
      Avoid infinite loop in ip addr flush.

Herbert Xu (1):
      xfrm: Allow replay setting

Patrick McHardy (1):
      tc: don't set protococol field on filter delete

Rafael Almeida (1):
      Fixed installation when changing DESTDIR

Stephen Hemminger (12):
      Fix bad hash calculation because of signed address
      Change formatting of u32 back to default
      Use inet_pton to read ipv4 addresses
      ematch related bugfix and cleanup
      Update to 2.6.26-rc6 headers
      use correct hz for rto,ato
      Neighbor cache timer is in user hz
      timers are in user hz
      Fix array out of bounds problem
      Add warning message when MAX_FIELDS reached
      Update headers to 2.6.26
      Update snapshot

Varun Chandramohan (1):
      Display Correct Error For Addrlabel Info

Yu Zhiguo (1):
      Fix generic_proc_open() of command 'nstat' and 'rtacct'

jamal (2):
      Expose the filter protocol
      Infrastructure for pretty printing

