From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/6] net-next: replace obsolete NLMSG_* with type safe
 nlmsg_*
Date: Thu, 28 Mar 2013 18:01:42 +0000
Message-ID: <20130328180142.GJ23043@casper.infradead.org>
References: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
 <20130328143216.GC23043@casper.infradead.org>
 <CAA7+ByVp4K__=mESAu4jEy=t4TJD+rV0KOA2ZhHSinm1fvedzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org
To: Hong zhi guo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35822 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360Ab3C1SBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 14:01:44 -0400
Content-Disposition: inline
In-Reply-To: <CAA7+ByVp4K__=mESAu4jEy=t4TJD+rV0KOA2ZhHSinm1fvedzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/13 at 12:08am, Hong zhi guo wrote:
> Thanks, Thomas. But I didn't change any formatting. Just do the
> substitution in place.

Your change would require reformatting on the lines following
your change because the required level of indentation changed.
I don't want to cause you unneeded pain but it really helps
everyone used to the kernel coding style.

> >> -     rep = alloc_skb(NLMSG_SPACE((sizeof(struct inet_diag_msg) +
> >> -                                  sizeof(struct inet_diag_meminfo) +
> >> -                                  64)), GFP_KERNEL);
> >> +     rep = nlmsg_new(sizeof(struct inet_diag_msg) +
> >> +                                  sizeof(struct inet_diag_meminfo) + 64,
> >> +                                  GFP_KERNEL);
                           ^^^^^^^^^^^^^^

> Should I re-format and re-send the patch?

Yes please, just resubmit the patches that changed and include
a proper vN in the subject.
