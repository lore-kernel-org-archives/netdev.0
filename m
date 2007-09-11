From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
Date: Tue, 11 Sep 2007 12:40:34 -0400
Message-ID: <20070911164033.GA3754@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, baum@tehutinetworks.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55509 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616AbXIKQld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 12:41:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This introduces support for a line of 10GbE adapters made by Tehuti
Networks.  An attempt to get this included was made a few months ago and
since the driver has been re-factored based on Jeff's suggestions.

You can download a patch against Jeff's netdev-2.6#upstream tree here:

http://git.greyhouse.net/gospo/tehuti-netdev-26-upstream.patch

and I setup a git tree last night based off Linus' tree.  You can sync
with that here if you like:

http://git.greyhouse.net/gospo/tehuti-2.6.git

This driver is in good enough shape to go into at least Jeff's tree and
we can make fixes as they are needed.  I'm not convinced all endian
issues are completely flushed out and there are few more ethtool ops that
could be implemented, but they don't seem to prevent basic card
functionality on my systems.

