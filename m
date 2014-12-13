From: Nils Holland <nholland@tisys.org>
Subject: [bisected] tg3 broken in 3.18.0?
Date: Sat, 13 Dec 2014 02:14:08 +0100
Message-ID: <20141213011408.GA27568@teela.fritz.box>
References: <20141210230634.GA22884@teela.fritz.box>
 <5489CA3C.10803@gmail.com>
 <548B00CD.3030708@gmail.com>
 <20141212203134.GA23705@teela.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from celine.tisys.org ([85.25.117.166]:37778 "EHLO celine.tisys.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932591AbaLMBOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 20:14:12 -0500
Received: from teela.fritz.box (ip4d14050c.dynamic.kabel-deutschland.de [77.20.5.12])
	by celine.tisys.org (Postfix) with ESMTPSA id B3AC1514088B
	for <netdev@vger.kernel.org>; Sat, 13 Dec 2014 02:14:10 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20141212203134.GA23705@teela.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok folks,

I now took the time to bisect the issue that killed the tg3 network
interface on one of my boxes in 3.18.0. Beside me, at least one other
person was affected, although we also have a confirmed report of
another person using tg3 without issues under 3.18.0.

My bisect exercise suggests that the following commit is the culprit:

89665a6a71408796565bfd29cfa6a7877b17a667 (PCI: Check only the Vendor
ID to identify Configuration Request Retry)

In case that rings a bell for anyone, I'd be more than glad to hear
about it! Otherwise, while I'm no expert at this, I'll do some more
investigations tomorrow. It's gotten kind of late during bisecting and
I'm off for some sleep now. ;-)

Greetings,
Nils
