From: David Miller <davem@davemloft.net>
Subject: Re: Rules and groups
Date: Wed, 09 Aug 2006 16:00:34 -0700 (PDT)
Message-ID: <20060809.160034.63994773.davem@davemloft.net>
References: <20060809080139.GA19555@souterrain.chygwyn.com>
	<20060809.010125.78708459.davem@davemloft.net>
	<20060809100326.GA23935@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57752
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751419AbWHIXAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 19:00:53 -0400
To: steve@chygwyn.com
In-Reply-To: <20060809100326.GA23935@souterrain.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <steve@chygwyn.com>
Date: Wed, 9 Aug 2006 11:03:26 +0100

> [DECnet] Covert rules to use generic code
> 
> This patch converts the DECnet rules code to use the generic
> rules system created by Thomas Graf <tgraf@suug.ch>.
> 
> Signed-off-by: Steven Whitehouse <steve@chygwyn.com>

Patch applied, thanks Steven.

I know it may seem like a minor detail, but can you format your top
comment line like this:

[DECNET]: Covert rules to use generic code

I've been making this transformation by hand.

The important parts for me are:

[X]: blah

Where X is the main subsystem name in all capital letters,
and there is a colon after the closing right bracket.  If
there is a specific sub-area being effected, the following
is a nice way to show that:

[X] subarea: blah

This makes all of the networking changesets look consistent
and it's easier for human eyes to scan the changeset lines
if we make an effort to do it this way.

Thanks!

