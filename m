From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] dccp ccid-3: High-res or low-res timers?
Date: Tue, 18 Nov 2008 06:07:35 +0100
Message-ID: <20081118050735.GB3846@gerrit.erg.abdn.ac.uk>
References: <5bc4c4570811061405qe72e43cx861c537885804132@mail.gmail.com> <20081108085035.GA7112@gerrit.erg.abdn.ac.uk> <20081115105042.GA7798@gerrit.erg.abdn.ac.uk> <20081116.224834.166724077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: leandroal@gmail.com, acme@redhat.com, ian.mcdonald@jandi.co.nz,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:50643 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750944AbYKRFIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 00:08:35 -0500
Content-Disposition: inline
In-Reply-To: <20081116.224834.166724077.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, -
| > Summing up, I have doubts that basing CCID-3 will bring advantages and
| > would much rather go the other way and (consistently) use lower resolution.
| > 
| > Thoughts?
| 
| I wouldn't bother with high resolution timers, mostly because they are more
| expensive and the benefit of them here is at best "unknown".
| 
Thanks a lot for the reply. I am glad for this suggestion, since it will
allow simpler code while at the same time still supporting a basic,
working implementation of CCID-3.

If people want to experiment with higher-resolution timers (as per other
replies), this can be put into an experimental subtree on 
eden-feed.erg.abdn.ac.uk.

If it is okay with Leandro and Tommi, it would finally also make it
possible to sort out consolidating the CCID-3/CCID-4 code.

Thanks again,
Gerrit
