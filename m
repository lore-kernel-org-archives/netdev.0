From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: RCU stall in af_unix.c, should use spin_lock_irqsave?
Date: Tue, 21 Oct 2014 12:08:52 +0200
Message-ID: <1413886132.32553.14.camel@localhost>
References: <20141021100313.397f4962@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexandre FOURNIER <alexandre.fournier@wisp-e.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Gregory =?ISO-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:43535 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751331AbaJUKIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 06:08:55 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id 8DDAD20790
	for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 06:08:54 -0400 (EDT)
In-Reply-To: <20141021100313.397f4962@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2014-10-21 at 10:03 +0200, Thomas Petazzoni wrote:
> So, the question is: is this patch the correct solution (but then other
> usage of spin_lock in af_unix.c might also need fixing) ? Or is the
> network driver at fault?

It feels like a false positive. Do you see one core spinning tightly on
a lock? Does the system get unusable?

Bye,
Hannes
