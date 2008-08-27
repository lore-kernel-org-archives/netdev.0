From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 04:45:51 -0700 (PDT)
Message-ID: <20080827.044551.102233262.davem@davemloft.net>
References: <1ba2fa240808270305m7f505efak9fd0d36d5db09a1e@mail.gmail.com>
	<1219831828.3891.3.camel@johannes.berg>
	<1ba2fa240808270434y1589761xd2ff0a48c2e99033@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, holtmann@linux.intel.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tomasw@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754153AbYH0Lp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 07:45:56 -0400
In-Reply-To: <1ba2fa240808270434y1589761xd2ff0a48c2e99033@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tomas Winkler" <tomasw@gmail.com>
Date: Wed, 27 Aug 2008 14:34:28 +0300

> Unfortunately fixing bugs on stable branch take precedence  of
> adjusting to new API on development branch that someone decided to do.
>  I wanted to work directly on wireless testing but it was broken over
> an over and I have only limited resources more in testing then in
> development I just had to branch out to be ready with the driver when
> HW is out. People just check the immediate impact of they fix the
> don't test for collateral damage and this is understandable an
> individual developer doesn't have lab with IBSS, BSS, AP, etc setups.

But think about this from the other perspective.

When you queue up tons of things, especially in infrastructure level
code such as mac80211, and on top of it you do your work on the stable
branch and do not do you work against the development tree, guess what
happens?

You show up with accumulated piles of non-trivial patches for people
to review.  And then you'll get upset when they suggest that things be
implemented differently.

It's all because of the gap in time.

And during this time, if you had submitted earlier, you would end up
doing smaller and mode gradual modifications to your design.  And
you'd take care of them before they effect subsequent pieces of work
you want to do which depend upon the earlier bits.

The longer you queue stuff up, the more painful having to change stuff
at the beginning of that queue becomes.  It can invalidate everything
else you worked on.

The only sane way to operate is to post your work early and often, or
else you'll live in a world of hurt, and it will be nobody's fault but
your own.

