From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: softmac: semantics of SIOCSIWFREQ
Date: Mon, 17 Apr 2006 13:01:39 -0700
Message-ID: <20060417200139.GA28626@bougret.hpl.hp.com>
References: <1145190888.6560.22.camel@localhost> <20060417163759.GB28203@bougret.hpl.hp.com> <1145299691.4116.11.camel@localhost> <20060417190649.GA28534@bougret.hpl.hp.com> <1145302029.4116.14.camel@localhost>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, softmac-dev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tayrelbas03.tay.hp.com ([161.114.80.246]:15330 "EHLO
	tayrelbas03.tay.hp.com") by vger.kernel.org with ESMTP
	id S1750818AbWDQUBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 16:01:43 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1145302029.4116.14.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 17, 2006 at 09:27:09PM +0200, Johannes Berg wrote:
> On Mon, 2006-04-17 at 12:06 -0700, Jean Tourrilhes wrote:
> 
> > 	Definitely. I was just pointing out that scanning behaviour is
> > not dictated by current setting of the drivers (except when the
> > hardware does it, cf. Ornoco).
> 
> Yeah, I was just repeating it for Ulrich :)
> 
> > 	For freq, it's simpler. In managed mode, it's never 'fixed',
> > because the card/driver choose the frequency. In master mode, it's
> > almost always 'fixed', because the user has to set the frequency. In
> > ad-hoc mode, it depend in the node creates or not the IBSS.
> 
> But isn't that a detail the user shouldn't have to know? See, if a node
> with a higher TSF joins the IBSS, then it gets to send out the beacons
> for it, IIRC.

	Who sent the beacon is different from who created the IBSS. If
you don't like this proposal, here is another one : if in ad-hoc mode
the actual IBSS freq is the same as what the user set, then set the
'fixed' flag, otherwise report the actual freq without the 'fixed'
flag.
	Or if you have another meaningful use of the flag in ad-hoc
mode, just shout.

> johannes

	Jean

