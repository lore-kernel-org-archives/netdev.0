From: Florian Zumbiehl <florz@gmx.de>
Subject: Session ID 0 with PPPoE
Date: Sun, 4 Mar 2007 03:30:00 +0100
Message-ID: <20070304023000.GF28150@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, mostrows@speakeasy.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbf844.pool.mediaWays.net ([217.187.248.68]:3529 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbXCDCaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 21:30:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I noticed that the PPPoE code doesn't allow session id 0x0000 to be used
for an actual session but rather considers 0 a special value denoting
that the socket is unbound. Now, when reading RFC 2516, I couldn't really
find anything that would forbid 0x0000 as a session id. Only 0xffff "is
reserved for future use and MUST NOT be used", while 0x0000 is specified
as the only allowed value for the session id field on certain types of
packets, but neither can I find any statement that forbids 0x0000 as
an ordinary session identifier, nor can I find any reasons that would
prevent PPPoE from functioning properly with a session id of 0x0000.

Does anyone of you see any reason why a server would not be allowed to
select 0x0000 as the session id for a PPPoE session?

Florian
