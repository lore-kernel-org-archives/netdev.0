From: Roger Luethi <rl@hellgate.ch>
Subject: [RFC] ethtool semantics
Date: Mon, 7 Jun 2004 23:28:04 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040607212804.GA17012@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265091AbUFGVmZ@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>,
	Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

What is the correct response if a user passes ethtool speed or duplex
arguments while autoneg is on? Some possible answers are:

a) Yell at the user for doing something stupid.

b) Fail silently (i.e. ignore command).

c) Change advertised value accordingly and initiate new negotiation.

d) Consider "autoneg off" implied, force media accordingly.

The ethtool(8) man page I'm looking at doesn't address that question. The
actual behavior I've seen is b) which is by far my least preferred
solution.

Roger
