From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 14:04:58 -0700 (PDT)
Message-ID: <20080819.140458.236030589.davem@davemloft.net>
References: <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
	<20080819.131454.223684377.davem@davemloft.net>
	<alpine.LFD.1.10.0808191341150.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751102AbYHSVE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 17:04:58 -0400
In-Reply-To: <alpine.LFD.1.10.0808191341150.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 19 Aug 2008 13:47:59 -0700 (PDT)

> Same goes for all the loopback changes. They look like cleanups or feature 
> enables.

Those fix a performance regression reported by a real user.

Sure I did a cleanup of dead code in one of those commits,
but if you look at the commit beforehand from Herbert, the
context, you can see that it made no sense to leave that
in there any longer as half of what it was standing there
as "documenting" was removed by Herbert's commit.
