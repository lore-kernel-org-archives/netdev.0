From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Sat, 10 May 2008 21:34:31 -0700 (PDT)
Message-ID: <20080510.213431.193696750.davem@davemloft.net>
References: <20080507.141521.193714938.davem@davemloft.net>
	<482498D5.9060008@krogh.cc>
	<48258074.7060306@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750709AbYEKEeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2008 00:34:37 -0400
In-Reply-To: <48258074.7060306@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Krogh <jesper@krogh.cc>
Date: Sat, 10 May 2008 13:01:08 +0200

> Any good suggestions about the "Transmit timed out" messages. It
> currently leads to a system that "doesnt die" but doesnt respond within
> 15 minutes of load of the network adapter.

It's likely some bug in the driver that hangs the card for whatever
reason, which we'll need to work out.

> Does the high amount of Context-switches (120.000+ have any influence)?

Unlikely.

> Should I be able to use TSO?

NIU doesn't support TSO.
