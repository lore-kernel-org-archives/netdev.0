From: David Miller <davem@davemloft.net>
Subject: Re: time for TCP ECN defaulting to on?
Date: Tue, 04 Nov 2008 14:52:42 -0800 (PST)
Message-ID: <20081104.145242.112948002.davem@davemloft.net>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
	<49107543.5080207@blueteddy.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.blueman@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-net@vger.kernel.org
To: linux-kernel@blueteddy.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754043AbYKDWxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 17:53:07 -0500
In-Reply-To: <49107543.5080207@blueteddy.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Hudson <linux-kernel@blueteddy.net>
Date: Tue, 04 Nov 2008 16:16:03 +0000

> Daniel J Blueman wrote:
> > Is it time to enable TCP ECN per default and get the benefits, since
> > router support has been around and known-about for really considerable
> > time?
> > Perhaps it should be a question of enabling it, and educating people
> > to disable it if they run into issues, since we'll probably be in the
> > same situation in 5 years...and it'll be some time before these
> > kernels hit devices/servers anyway.
> > Daniel
>
> Unfortunately I think you'll find there are sufficiently large
> numbers of broken SOHO routers out there that if you try this you'll
> cause a lot of problems.  The problems range from no connectivity to
> in a few extreme cases routers actually crashing or behaving in very
> unpredictable ways.  Here's one summary that got presented to the
> IETF about 18 months ago:
>
> http://www.ietf.org/proceedings/07mar/slides/tsvarea-3/sld6.htm

Another issue is that, even if we turn it on by default, it won't
be on for a significant number of network cards out there.

This is because TSO, which is on by default, doesn't support ECN
in many implementations.
