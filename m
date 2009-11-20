From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Fri, 20 Nov 2009 14:52:24 -0800 (PST)
Message-ID: <20091120.145224.181250500.davem@davemloft.net>
References: <65634d660911160843j3df398f2w876044083181cfcd@mail.gmail.com>
	<20091119080831.GA6874@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753757AbZKTWwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 17:52:08 -0500
In-Reply-To: <20091119080831.GA6874@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 19 Nov 2009 08:08:31 +0000

> On 16-11-2009 17:43, Tom Herbert wrote:
>> NET_RPS_SOFTIRQ is intended to provide coalescing of IPIs.
> 
> It seems calling net_rps_action() at the end of net_rx_action() should
> do (mostly) the same, at least for napi drivers. And I'm not sure it's
> worth to add a new softirq because of non-napis.

I agree.  This is how we handle all of these kinds of issues.

And with GRO, any arguable latency problem this may have you're
going to eat most of the time anyways.
