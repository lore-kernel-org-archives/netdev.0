From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix RPF to work with policy routing
Date: Thu, 22 Oct 2009 21:49:43 -0700 (PDT)
Message-ID: <20091022.214943.105371652.davem@davemloft.net>
References: <1255867954.4815.25.camel@dogo.mojatatu.com>
	<1255868019.4815.27.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, atis@mikrotik.com, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42230
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750864AbZJWEtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 00:49:21 -0400
In-Reply-To: <1255868019.4815.27.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sun, 18 Oct 2009 08:13:39 -0400

> On Sun, 2009-10-18 at 08:12 -0400, jamal wrote:
>> policy routing never worked with mark.
> 
> I meant policy routing, mark and RPF never worked together ;->

Is this actually valid?

Such a change has a built-in assumption, I think, that
marks are symmetric.

Just because we ended up with mark X on input doesn't mean
that the reverse path route exists with mark X too.

In fact I can't even see a valid way to specify a mark for
the RPF lookup.

Maybe you can convince me otherwise :-)
