From: Chris J Arges <chris.j.arges@canonical.com>
Subject: [3.10.y-3.15.y][stable request] netfilter: nf_nat: fix oops on netns
 removal
Date: Thu, 26 Jun 2014 15:38:09 -0500
Message-ID: <53AC84B1.8080405@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, pablo@netfilter.org
To: davem@davemloft.net, kamal@canonical.com,
	samu.kallio@aberdeencloud.com,
	Luis Henriques <luis.henriques@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35139 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbaFZUiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 16:38:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Please include commit 945b2b2d259d1a4364a2799e80e8ff32f8c6ee6f in the
netdev stable queue and any other appropriate stable trees. This fixes a
race condition that can be triggered when cleaning up LXC containers
that use NAT/netns. The patch has already received positive testing when
backported to 3.13.y.

The patch cleanly cherry-picks from 3.10.y to 3.15.y.

Upstream bug:
https://bugzilla.kernel.org/show_bug.cgi?id=65191
Ubuntu bug:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1314274

Fixes: c2d421e1718 ('netfilter: nf_nat: fix race when unloading protocol
modules')

This also potentially affects v3.9.y and other stable trees such as
v3.8.y that have backported the above patch; however it is not a clean
cherry-pick for those versions. I'll work on a patch in this case and
send a separate email.

--chris j arges
