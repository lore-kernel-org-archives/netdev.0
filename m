From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH net-next] qla4xxx: add a missing include
Date: Wed, 27 May 2015 11:33:14 -0700
Message-ID: <1432751594.2194.54.camel@HansenPartnership.com>
References: <1432701824.4060.346.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150527.142117.1711665345600870663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:59547 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751517AbbE0SdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:33:16 -0400
In-Reply-To: <20150527.142117.1711665345600870663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 14:21 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 26 May 2015 21:43:44 -0700
> 
> > From: Eric Dumazet <edumzet@google.com>
> > 
> > vmalloc.h used to be included from include/net/inet_hashtables.h
> > but it is no longer the case.
> > 
> > Fixes: 095dc8e0c368 ("tcp: fix/cleanup inet_ehash_locks_alloc()")
> > Reported-by: kbuild test robot <fengguang.wu@intel.com>
> > Signed-off-by: Eric Dumazet <edumzet@google.com>
> > ---
> > Given its broken in David net-next tree, its probably simpler
> > that David merges this fix directly ? Thanks !
> 
> Yeah it's easiest if I just apply this to net-next, which I've just done,
> thanks Eric.

Fine with me.  There's no point creating cross tree hassle for a simple
include problem.

James
