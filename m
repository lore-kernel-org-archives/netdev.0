From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Tue, 08 Mar 2011 11:43:46 -0800 (PST)
Message-ID: <20110308.114346.48506864.davem@davemloft.net>
References: <il4vur$3ka$1@dough.gmane.org>
	<20110308111011.GA27967@xanadu.blop.info>
	<4D764AAC.30302@ncsu.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucas.nussbaum@loria.fr, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: rhee@ncsu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36096
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755706Ab1CHTnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 14:43:09 -0500
In-Reply-To: <4D764AAC.30302@ncsu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Injong Rhee <rhee@ncsu.edu>
Date: Tue, 08 Mar 2011 10:26:36 -0500

> Thanks for updating CUBIC hystart. You might want to test the
> cases with more background traffic and verify whether this
> threshold is too conservative.

So let's get down to basics.

What does Hystart do specially that allows it to avoid all of the
problems that TCP VEGAS runs into.

Specifically, that if you use RTTs to make congestion control
decisions it is impossible to notice new bandwidth becomming available
fast enough.

Again, it's impossible to react fast enough.  No matter what you tweak
all of your various settings to, this problem will still exist.

This is a core issue, you cannot get around it.

This is why I feel that Hystart is fundamentally flawed and we should
turn it off by default if not flat-out remove it.

Distributions are turning it off by default already, therefore it's
stupid for the upstream kernel to behave differently if that's what
%99 of the world is going to end up experiencing.

