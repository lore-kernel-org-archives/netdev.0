From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
 submit to upper layer
Date: Fri, 13 Mar 2009 19:19:51 -0700 (PDT)
Message-ID: <20090313.191951.228619450.davem@davemloft.net>
References: <65634d660903131459m645eb468y3ad850a1fd56d447@mail.gmail.com>
	<20090313.151913.21135937.davem@davemloft.net>
	<65634d660903131724s49009177pdc11005aa76a4b56@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, bhutchings@solarflare.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47447
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752500AbZCNCUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 22:20:06 -0400
In-Reply-To: <65634d660903131724s49009177pdc11005aa76a4b56@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 13 Mar 2009 17:24:10 -0700

> Enabling HW multi-queue has somewhat higher CPU
> utilization though, the extra device interrupt load is not coming for
> free.  We actually use the HW multi-queue in conjunction with our
> software steering to get maximum pps (about 20% more).

This is a non-intuitive observation.  Using HW multiqueue should be
cheaper than doing it in software, right?
