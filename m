From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Tue, 17 Nov 2009 23:21:47 -0800 (PST)
Message-ID: <20091117.232147.59648714.davem@davemloft.net>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
	<20091116.031914.65020185.davem@davemloft.net>
	<65634d660911160843j3df398f2w876044083181cfcd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51287
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751330AbZKRHVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 02:21:30 -0500
In-Reply-To: <65634d660911160843j3df398f2w876044083181cfcd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 16 Nov 2009 08:43:05 -0800

> On Mon, Nov 16, 2009 at 3:19 AM, David Miller <davem@davemloft.net> wrote:
>> {,__}send_remote_softirq() doesn't work? :-)
>>
> NET_RPS_SOFTIRQ is intended to provide coalescing of IPIs.
> 
> send_remote_softirq could be used, but we would also need to get the
> napi structure on the remote cpu poll list so that would probably need
> to be protected by locks (something like __napi_schedule_oncpu could
> be defined).  Would this be better to do?

We talked about this several times in the past too.  Let me think some
more about this, I want to consider all of the issues a bit before
making any suggestions.

Thanks.
