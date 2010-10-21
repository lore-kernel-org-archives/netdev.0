From: kaber@trash.net
Subject: [PATCH 00/72] netfilter: netfilter update for 2.6.37
Date: Thu, 21 Oct 2010 17:18:47 +0200
Message-ID: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59978 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057Ab0JUPUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the following patches contain my netfilter update for 2.6.37, containing:

- xtables and ebtables cleanups from Jan

- NAT cleanups and optimizations from Changli

- a fix for a race condition in netfilter hash random initialization and
  caching of the original hash value from the lookup for hash insertion
  from Changli

- smaller ctnetlink fixes and support for user-space connection tracking
  helpers from Pablo

- ctnetlink expectation deletion event notifications from Pablo

- a patch from Eric to make the LOG targets build the entire log string
  in a buffer before printing it to save some overhead and avoid having
  the log message intermixed with unrelated printks

- a TPROXY fix for dealing with TIME_WAIT sockets from Balazs

- a TPROXY fix for locking problems in __inet_inherit_port() from Balazs

- IPv6 TPROXY support from Balazs and Krisztian

- IPVS persistent engine core and SIP persistent engine from Simon

- IPVS IPv6 tunnel mode from Hans Schillstrom

- various IPVS fixes and optimizations from Julian

- IPVS support for local servers and clients from Julian

Please pull from:

git://git.kernel.org:/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!
