From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: SPLICE_F_NONBLOCK semantics...
Date: Thu, 1 Oct 2009 15:24:30 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0910011521550.6996@localhost.localdomain>
References: <20091001.151102.09812927.davem@davemloft.net> <alpine.LFD.2.01.0910011516390.6996@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, jgunthorpe@obsidianresearch.com,
	vl@samba.org, opurdila@ixiacom.com, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jens Axboe <jens.axboe@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43265 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753357AbZJAWYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 18:24:38 -0400
In-Reply-To: <alpine.LFD.2.01.0910011516390.6996@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 1 Oct 2009, Linus Torvalds wrote:
> 
> Ack. The original intent was for the flag to affect the buffering, not the 
> end points.

Side note, in case it wasn't clear: I added Jens to the cc, because in the 
end my "original intent" probably doesn't matter all that much. I may have 
set up the basic ideas and so on, but I never wrote any apps that use it, 
and Jens has done most of the actual fixes since.

So give "my original intent" the weight (or rather, lack there-of) that it 
deserves. 

		Linus
