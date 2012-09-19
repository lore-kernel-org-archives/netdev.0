From: michi1@michaelblizek.twilightparadox.com
Subject: [RFC] new connection-oriented layer 3+4 protocol
Date: Wed, 19 Sep 2012 19:08:53 +0200
Message-ID: <20120919170853.GJ2228@grml>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from michaelblizek.twilightparadox.com ([193.238.157.55]:50093 "EHLO
	michaelblizek.twilightparadox.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756645Ab2ISR3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 13:29:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I am programming a new layer 3+4 protocol for mesh networks. Basically it is
- connection oriented
- source (+optional onion) routed
- doing windowing between each neighbor on every connection (no congestion
  avoidance)
- using credits as a metric for QoS

The protocol especially tries to withstand DoS attacks and rough
users/application without human interference. This includes protection against
inserting bogus routes, blackholing/throttling, addressing conflicts (node
address can be a hashed public crypto key) and ressource contention. In theory
it could provide Byzantine robustness, but in practice the overhead for
calculating routes and ressource contention will limit how far this gets.

Right now the layer 3 is running somehow (without any crypto). The layer 4 is
currently rather incomplete and broken.

Project home:
http://michaelblizek.homelinux.net/projects/cor/index.html

Code:
http://repo.or.cz/w/cor.git/tree/HEAD:/net/cor

        -Michi
