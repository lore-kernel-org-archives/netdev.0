From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 16:49:29 -0400 (EDT)
Message-ID: <20110517.164929.1737248436066795381.davem@davemloft.net>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	<BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756566Ab1EQUtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 16:49:33 -0400
In-Reply-To: <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 17 May 2011 13:02:25 -0700

> I like it!  And this sounds like the sort of algorithm that NICs might
> be able to implement to solve the UDP/RSS unpleasantness, so even
> better.

Actually, I think it won't work.  Even Linux emits fragments last to
first, so we won't see the UDP header until the last packet where it's
no longer useful.

Back to the drawing board. :-/
