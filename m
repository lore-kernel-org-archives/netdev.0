From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH v2 net] tcp: Fix integer-overflows in TCP vegas
Date: Tue, 29 Jul 2014 11:52:27 +0200
Message-ID: <20140729095227.GD5038@cpaasch-mac>
References: <1406289159-30498-1-git-send-email-christoph.paasch@uclouvain.be>
 <20140728.172627.1679434888082672835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ncardwell@google.com,
	David.Laight@ACULAB.COM, doug.leith@nuim.ie
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:50369 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004AbaG2Jwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 05:52:34 -0400
Content-Disposition: inline
In-Reply-To: <20140728.172627.1679434888082672835.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/07/14 - 17:26:27, David Miller wrote:
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Fri, 25 Jul 2014 13:52:39 +0200
> 
> > +				target_cwnd = U32_MAX / rtt * upper + err / rtt;
> 
> Doing two divides is probably more expensive than using do_div().
> 
> Why don't we go back to the do_div() implementation, sorry about
> changing my mind again.

No worries :)
I will resubmit.


Cheers,
Christoph
