From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
 submit to upper layer
Date: Fri, 13 Mar 2009 14:02:17 -0700 (PDT)
Message-ID: <20090313.140217.143696945.davem@davemloft.net>
References: <65634d660903131006n44f068dw18b2fe9dce25399e@mail.gmail.com>
	<20090313.115137.254924980.davem@davemloft.net>
	<65634d660903131358h765bef64y6a0f1b0db7400f6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, bhutchings@solarflare.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750949AbZCMVCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 17:02:31 -0400
In-Reply-To: <65634d660903131358h765bef64y6a0f1b0db7400f6f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 13 Mar 2009 13:58:53 -0700

> We are trying to follow the decisions scheduler as opposed to
> leading it.  This works on very loaded systems, with applications
> binding to cpusets, with threads that are receiving on multiple
> sockets.  I suppose it might be compelling if a NIC could steer
> packets per flow, instead of by a hash...

If the hash is good is will distribute the load properly.

If the NIC is sophisticated enough (Sun's Neptune chipset is)
you can even group interrupt distribution by traffic type
and even bind specific ports to interrupt groups.

I really detest all of these software hacks that add overhead
to solve problems the hardware can solve for us.
