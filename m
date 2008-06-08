From: Thomas Zeitlhofer <tzeitlho+lkml@nt.tuwien.ac.at>
Subject: IPSEC in 2.6.25 causes stalled connections
Date: Sun, 8 Jun 2008 03:08:58 +0200
Message-ID: <20080608010858.GA8877@swan.nt.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swan.nt.tuwien.ac.at ([128.131.67.158]:46207 "EHLO
	swan.nt.tuwien.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755407AbYFHBT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2008 21:19:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have two machines (x86_64) connected via a direct network link (i.e.
directly connected by cable).

IPSEC is used for all traffic over this link. 

Everything works fine as long as the traffic is low. E.g. several
interactive ssh sessions are ok.

If a TCP or UDP connection (e.g. cat /dev/zero | netcat [-u] ...)
produces a lot of traffic then this connection typically stalls within
a couple minutes. Some but not all of the other open connections (e.g.
ssh sessions) get stuck too. The stalled connections do not recover and
the ssh sessions finally terminate with a timeout error.

This happens with 2.6.25.4 (also tested with 2.6.25) and IPSEC. Without
IPSEC there is no problem with stalled connections.

The problem also goes away if I switch back to 2.6.24.4.

Is this a known issue?

Thanks,

Thomas
