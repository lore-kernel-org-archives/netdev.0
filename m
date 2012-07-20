From: David Miller <davem@davemloft.net>
Subject: Re: [patch iproute2] iplink: add support for num[tr]xqueues
Date: Fri, 20 Jul 2012 11:10:01 -0700 (PDT)
Message-ID: <20120720.111001.1009240125448618151.davem@davemloft.net>
References: <lh9v01i5y1bg7t9j24kof0f8.1342799538355@email.android.com>
	<20120720180813.GA1560@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org,
	edumazet@google.com, shemminger@vyatta.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211Ab2GTSKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:10:02 -0400
In-Reply-To: <20120720180813.GA1560@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 20 Jul 2012 20:08:13 +0200

> Fri, Jul 20, 2012 at 05:52:18PM CEST, stephen.hemminger@vyatta.com wrote:
>>I like the option, but  numtxqueue is too verbose for the syntax model
>>of iproute. Why not use txq and rxq?
> 
> There is "txqueuelen" present already in iplink. I tried to be uniform here.
> Isn't "txq" and "rxq" rather too short? And afterall, these parameters
> are not supposed to be used on daily basis by anyone :)

Perhaps a good compromise is numtxq and numrxq?
