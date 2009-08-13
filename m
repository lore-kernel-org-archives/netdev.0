From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4, linux-2.6.30.4
Date: Thu, 13 Aug 2009 13:15:06 -0700 (PDT)
Message-ID: <20090813.131506.187121582.davem@davemloft.net>
References: <bb6e06c00908121147h2dab7d0kf5841a40956c5c56@mail.gmail.com>
	<20090812.145549.228391386.davem@davemloft.net>
	<4A8409CA.70200@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: slot.daniel@gmail.com, netdev@vger.kernel.org
To: hannemann@nets.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38230
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755876AbZHMUO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 16:14:56 -0400
In-Reply-To: <4A8409CA.70200@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Date: Thu, 13 Aug 2009 14:40:42 +0200

> Please correct me if I'm wrong or just too stupid to understand this stuff.
> (very likely;-)

You may be right, but at least the infrastructure for reordering
detection is there.

So instead of improving the stuff we have, to make it detect
when reordering goes away and potentially re-enable FACK, you're
simply adding something new to replace it.

Why not just fix up for the deficiencies you're aware of?
