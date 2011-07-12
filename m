From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PATCH] Fix deadlock in af_packet while stressing raw
 ethernet socket interface
Date: Mon, 11 Jul 2011 23:42:52 -0700 (PDT)
Message-ID: <20110711.234252.1252585261818390641.davem@davemloft.net>
References: <78567a0a1d2999f06d8f.1307768649@meeusr-laptop>
	<20110711.202717.1764669415135298036.davem@davemloft.net>
	<CAMJ=MEf8KkNNSvHy-pepg_GfkrnquKo+zW3GyB7RDAYO2H+SVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ronny.meeus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607Ab1GLGm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 02:42:56 -0400
In-Reply-To: <CAMJ=MEf8KkNNSvHy-pepg_GfkrnquKo+zW3GyB7RDAYO2H+SVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ronny Meeus <ronny.meeus@gmail.com>
Date: Tue, 12 Jul 2011 08:38:57 +0200

> Can you be a bit more specific on where the software interrupts should
> be disabled?

In all paths that lead to the packet capturing hooks, I can't
be any more specific than that, because that is the exact
requirement.
