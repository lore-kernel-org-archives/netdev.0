From: Michael Blizek <michi1@michaelblizek.twilightparadox.com>
Subject: [RFC] Connection oriented routing
Date: Thu, 26 Nov 2009 09:34:52 +0100
Message-ID: <20091126083452.GA1938@michaelblizek.twilightparadox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from michaelblizek.twilightparadox.com ([193.238.157.55]:35671 "EHLO
	michaelblizek.twilightparadox.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760069AbZKZJLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 04:11:42 -0500
Received: from [127.0.0.1] (helo=michaelblizek.twilightparadox.com)
	by michaelblizek.twilightparadox.com with smtp (Exim 4.69)
	(envelope-from <michi1@michaelblizek.twilightparadox.com>)
	id 1NDZpD-0008ES-VS
	for netdev@vger.kernel.org; Thu, 26 Nov 2009 09:35:40 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I am programming a new layer 3(+4) protocol for zero administration
(community/mesh) networks. It is source routed. Routers know about the
connections and can optionally do onion like reencryption. There is also a
QoS/credit system with explicit Xon/Xoff instead of "congestion avoidance". A
few things are already running (see
http://michaelblizek.twilightparadox.com/projects/cor/index.html ) for the
code and a few more ressources.

The drawback will be that ressource usage on the routers is likely higher than
IP. At the moment I do not know exactly how much higher. It seems like the
price, I just hope it is not too high.

	-Michi

