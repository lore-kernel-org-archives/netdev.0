From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCHv3 net-next 1/6] sctp: add sctp_info dump api for sctp_diag
Date: Mon, 18 Apr 2016 12:18:24 +0200
Message-ID: <20160418101824.GB14683@orbyte.nwl.cc>
References: <cover.1460618169.git.lucien.xin@gmail.com>
 <cover.1460618169.git.lucien.xin@gmail.com>
 <cd6bf9c2696f125a74491e1f82b77a30bb1005dd.1460618169.git.lucien.xin@gmail.com>
 <20160415.172858.253625178036493951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, marcelo.leitner@gmail.com,
	vyasevich@gmail.com, daniel@iogearbox.net, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40814 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751358AbcDRKS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2016 06:18:27 -0400
Content-Disposition: inline
In-Reply-To: <20160415.172858.253625178036493951.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2016 at 05:28:58PM -0400, David Miller wrote:
> Feedback was given here not to mix the changelog and the commit message.
> 
> And I want to explicitly state that I totally and _COMPLETELY_ disagree
> with this.
> 
> It is absolutely essential information and belongs in the commit message.
> 
> Adding more information never hurts, so don't do this crap of putting
> things that might be useful to know after the "---", ever.
> 
> Someone in the future might ask "why didn't he implement it like XXX"
> and the changelog can tell him that originally that is what was done
> and feedback was given to do it differently.

I see your point and am well aware the last word on this belongs to you.
Still I would like to explain why I disagree:

In my understanding, the changelog addresses reviewers only, so they
know what to expect or which new chunks to have another look at.  If the
changelog provides valuable information beyond that, I think the mistake
was to not update the commit message accordingly.

Imagine a patchset being rerolled ten times with massive changes in
between - do you really appreciate if the changelog applies to v1 only
and people have to read through nine increments to find out what is
actually being done?

Although I'm exaggerating, one could apply the same logic to the code
changes itself and demand v1 being applied as is with each evolution
separately on top, as otherwise information is lost.

Cheers, Phil
> 
> So Xin thanks for correctly putting the changelog inside of the commit
> message, so that future developers can benefit from this knowledge.
