From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: Change defaults on cookie hmac selection
Date: Fri, 14 Dec 2012 19:38:44 -0500
Message-ID: <20121215003844.GA10508@neilslaptop.think-freely.org>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
 <CA+55aFyT5b9GmGX0kzMPQG795uojiiWjWxUBBG_-m9bfrThU=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45914 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab2LOAjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 19:39:10 -0500
Content-Disposition: inline
In-Reply-To: <CA+55aFyT5b9GmGX0kzMPQG795uojiiWjWxUBBG_-m9bfrThU=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2012 at 01:56:15PM -0800, Linus Torvalds wrote:
> On Fri, Dec 14, 2012 at 10:51 AM, Neil Horman <nhorman@tuxdriver.com> wrote:
> >
> > Tested by myself (allbeit fairly quickly).  All configuration combinations seems
> > to work soundly.
> 
> Ok, looks good, but I suspect we should also re-introduce the "none"
> choice we used to have.
> 
> No?
> 
No need, I think.  Since its a user configurable choice now, the user can just
set the selector to "None" in proc, and none will be used.

Neil
