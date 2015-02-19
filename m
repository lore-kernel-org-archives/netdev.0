From: James Minor <james.minor@ni.com>
Subject: Re: [PATCH RFC] wext: Add event stream wrappers that return E2BIG
 when values don't fit
Date: Thu, 19 Feb 2015 15:31:11 -0600
Message-ID: <54E6561F.4050109@ni.com>
References: <1422565452-19825-1-git-send-email-xander.huff@ni.com> <1422566529.6322.26.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	joseph.hershberger@ni.com, ben.shelton@ni.com, jaeden.amero@ni.com,
	joshc@ni.com, rich.tollerton@ni.com, brad.mouring@ni.com
To: Johannes Berg <johannes@sipsolutions.net>,
	Xander Huff <xander.huff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422566529.6322.26.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/29/2015 03:22 PM, Johannes Berg wrote:

> > What you mean is "with the wext (compatibility) code in cfg80211".

Comment fixed in the v2 of the patch (coming shortly).

> > Either way, I *strongly* recommend against using this in the first
> > place. There's an upper bound of 64k (I think) on the amount of memory
> > that can be used, and people have been known to run into this limit - at
> > which point you get absolutely no scan results back whatsoever. It's far
> > safer to use nl80211's scan dump, and if you're looking at this code in
> > particular then clearly you have it available.

Agreed, and we will be switching to nl80211 as soon as we can.

> > Regarding the patch itself, it seems to add a bit much code. Is there
> > really no better way to express this? Perhaps by checking that the
> > stream actually moved forward - which will *always* happen for any of
> > these functions if they actually did anything? Even maybe if the new
> > _check inlines were to do that it'd still make the code smaller.

I've shuffled some things around and will submit the v2 momentarily.


Thanks,
James
