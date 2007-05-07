From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 1/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Mon, 07 May 2007 22:54:53 +0200
Message-ID: <m3k5vkfj6q.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3y7k1biov.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705070343330.2733@scrub.home>
	<m3tzupc6wz.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071318150.1479@scrub.home>
	<m3r6psc0ee.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071509290.1479@scrub.home>
	<463F27CE.2040008@garzik.org>
	<Pine.LNX.4.64.0705071538060.1479@scrub.home>
	<m3lkg0a88y.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071901020.1479@scrub.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Roman Zippel <zippel@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:41328 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966860AbXEGUyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 16:54:55 -0400
In-Reply-To: <Pine.LNX.4.64.0705071901020.1479@scrub.home> (Roman Zippel's message of "Mon, 7 May 2007 19:07:43 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roman Zippel <zippel@linux-m68k.org> writes:

> Normal dependencies, you basically have to manually make sure they are 
> correct (and it seems with your patch they aren't). Again, _please_ (with 
> sugar on top) don't use select unless you have a good reason for it.

You perhaps mean WAN dependency, don't you? I was under impression
that the "menu" patches have already been merged so the WAN
dependency would be automatic.

Anything other than that? Sure, I can see now. I can only say,
in my defense, that I was (and still am) very tired. I'm going to
get some coffee.

There is still a very good reason for the select.
CONFIG_HDLC _is_ a simple library, though probably not the most
simple one. I really feel it's an improvement.

Attaching two patches, hopefully the double check is enough.
-- 
Krzysztof Halasa
