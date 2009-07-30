From: Roland Dreier <roland@digitalvampire.org>
Subject: Re: IPv6 default routes timing out?
Date: Thu, 30 Jul 2009 13:58:25 -0700
Message-ID: <87d47h7ury.fsf@shaolin.home.digitalvampire.org>
References: <874osv8jyo.fsf@shaolin.home.digitalvampire.org>
	<1248914038.13447.17.camel@merlyn>
	<87k51q6raq.fsf@shaolin.home.digitalvampire.org>
	<1248975058.7167.28.camel@Maple> <aday6q6qatu.fsf@cisco.com>
	<1248984555.8639.4.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:54542 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751935AbZG3U6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:58:37 -0400
In-Reply-To: <1248984555.8639.4.camel@Maple> (John Dykstra's message of "Thu, 30 Jul 2009 20:09:15 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Note that these are actually multicasts, not broadcasts.  There's not
 > much difference on the sending end, but on the receiving end there's
 > usually filtering at the NIC level that doesn't apply to broadcasts.
 > 
 > That's why I'm a little bit suspicious of the laptop end of your
 > connection.  It's not uncommon for multicast to be broken in various
 > ways without people noticing, because they don't use it very much on
 > IPv4.  However, it's fundamental to IPv6.

Fair enough ... however, given that two independent laptops (using two
different wireless drivers / kernel versions) stop getting the router
advertisements (which are, as you said, multicast to the all nodes
address, not truly broadcast) at the same time, and given that
bouncing the driver on the sender (openbsd router) fixes things, I'm
much more likely to blame the sender in this case.
