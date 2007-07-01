From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sun, 1 Jul 2007 22:20:39 +0200
Message-ID: <200707012220.39436.mb@bu3sch.de>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <200707011223.17235.mb@bu3sch.de> <20070701150006.GE7929@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: =?iso-8859-1?q?T=F6r=F6k_Edvin?= <edwintorok@gmail.com>,
	zambrano@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, power@bughost.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:41201
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759268AbXGAUW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 16:22:29 -0400
In-Reply-To: <20070701150006.GE7929@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 01 July 2007 17:00:06 Lennert Buytenhek wrote:
> A multimeter should do the trick, but I would advise against this
> if you're not totally comfortable with hacking hardware.

Ok, the resistor on the board is 100ohm, which is too big
according to the docs of the extender.
So what I tried is to connect a 10ohm resistor between
IDSEL and the AD pin, on the extender itself. But it didn't
do the trick. It still doesn't work.
I also connected a 10ohm resistor between IDSEL and the AD
pin directly on the mainboard. Also doesn't work. So I guess
it's some other issue.
But I have no idea what could be wrong besides that.

-- 
Greetings Michael.
