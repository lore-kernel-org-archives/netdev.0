From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v5 00/14] Labeled networking patches for 2.6.28
Date: Fri, 05 Sep 2008 19:23:12 -0400
Message-ID: <20080905231853.31840.57880.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:38277 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbYIEXXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 19:23:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new spin to fix problems pointed out by Andrew Mortion and Randy Dunlap
as well as some minor things found by James Morris during review.  Thanks
to all three for the extra sets of eyes.

This patchset also has a slight change in it which involves moving the
SELinux packet parsing (to determine protocol, address, etc.) farther down
in the SELinux per-packet processing routines.  This should help reduce
some wasted cycles, especially in the unconfigured case.

I've updated both my lblnet-2.6_testing and lblnet-2.6_next trees with
the new bits:

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_testing
 * git://git.infradead.org/users/pcmoore/lblnet-2.6_next

--
paul moore
linux @ hp
