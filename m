From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 0/4 for 2.6.31] NET: Revive fixed link support
Date: Sat, 27 Jun 2009 02:29:00 +0400
Message-ID: <20090626222900.GA14594@oksana.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Li Yang <leoli@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:11802 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750875AbZFZW3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 18:29:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

The fixed link support is broken since The Big OF MDIO Rework,
the rework simply removed most of the code that was needed for
fixed links.

Too bad I didn't notice this earlier, I saw a bunch of patches
on the ml, but unfortunately I didn't look very close presuming
that Grant knew what he was doing. :-) And obviously I didn't
test linux-next on anything that requires a fixed link.

Anyway, here are four patches. The first one adds the fixed link
support to a framework, otherwise we'd duplicate the code across
the drivers (as we did previously), and I tried to keep drivers'
changes minimal.

Patches 2 and 3 are for the drivers that I tested in run-time,
with normal PHYs, and fixed links.

Patch #4 was build-tested, but I believe it should work in
run-time too.


Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
