From: David Miller <davem@davemloft.net>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Mon, 02 Aug 2010 22:13:41 -0700 (PDT)
Message-ID: <20100802.221341.137851732.davem@davemloft.net>
References: <20100802110334.GK11110@cel.leo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leonerd@leonerd.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751189Ab0HCFNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 01:13:22 -0400
In-Reply-To: <20100802110334.GK11110@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Date: Mon, 2 Aug 2010 12:03:34 +0100

> Any comments on this, while I proceed? Barring any major complaints,
> I'll have a hack at some code and present a patch in due course...

We're not adding loop instructions, it's just asking for trouble
since any user can attach BPF filters to a socket and it's just
way too easy to make a loop endless.

There's a reason no loop primitives were added to the original
BPF specification, perhaps you should take a look at what their
reasoning was.

It still applies now.
