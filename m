From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: TX abort errors on GRE tunnels
Date: Mon, 25 May 2015 14:39:05 -0400
Message-ID: <1432579145.32671.61.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:60697 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750837AbbEYSjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 14:39:10 -0400
Received: from [10.3.0.5] ([69.74.118.2]) by mrelay.perfora.net (mreueus002)
 with ESMTPSA (Nemesis) id 0LaVAX-1ZPvFK0A2B-00mNJZ for
 <netdev@vger.kernel.org>; Mon, 25 May 2015 20:39:09 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  We are seeing TX abort errors on all of our GRE tunnels.
What would cause such a thing? We suspected it might be MTU because
these are encapsulated in IPSec transport and the MTU on the GRE tunnel
is still 1476 so we reduced the MTU but that did not eliminate the
problem.

By the way, I submitted a separate thread about TCP windowing problems
inside GRE tunnels but those test tunnels are not generating the TX
abort errors.  Thanks - John
