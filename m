From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: correct include file  for restart_syscall
Date: Mon, 13 Dec 2010 12:17:16 +0200
Message-ID: <Pine.LNX.4.64.1012131211001.17382@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Roland Dreier <rdreier@cisco.com>, <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:44652 "EHLO
	Exil2010.voltaire.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752324Ab0LMKRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 05:17:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

commit 26574401fef6766f6c3ca25b5c13febe662d2a32 "net: Fix ipoib rtnl_lock
sysfs deadlock" modified some flows doing rtnl_lock calls to use rtnl_trylock
/ restart_syscall, etc. It turned out that restart_syscall was included in
ipoib through linux/inet_lro.h which is an include I'd like to remove...
Is including linux/sched.h being the right thing to do? I wasn't sure as
this call is very rare, in network drivers its called only by ipoib and
bonding and it looks like bonding includes it indirectly.

Or.

