From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
 submit to upper layer
Date: Fri, 13 Mar 2009 15:19:13 -0700 (PDT)
Message-ID: <20090313.151913.21135937.davem@davemloft.net>
References: <65634d660903131358h765bef64y6a0f1b0db7400f6f@mail.gmail.com>
	<20090313.140217.143696945.davem@davemloft.net>
	<65634d660903131459m645eb468y3ad850a1fd56d447@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, bhutchings@solarflare.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59966
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754683AbZCMWT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 18:19:27 -0400
In-Reply-To: <65634d660903131459m645eb468y3ad850a1fd56d447@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 13 Mar 2009 14:59:55 -0700

> I appreciate this philosophy, but unfortunately I don't have the
> luxury of working with a NIC that solves these problems.  The reality
> may be that we're trying to squeeze performance out of crappy hardware
> to scale on multi-core.  Left alone we couldn't get the stack to
> scale, but with these "destable hacks" we've gotten 3X or so
                         ^^^^^^^^

Spelling.

> improvement in packets per second across both our dumb 1G and 10G
> NICs

Do these NICs at least support multiqueue?
