From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 1/2] sfc: Support setting rss_cpus to 'cores',
 'packages' or 'hyperthreads'
Date: Mon, 9 May 2016 13:00:01 +0100
Message-ID: <57307BC1.5030103@solarflare.com>
References: <572A29AF.1040607@solarflare.com>
 <572A2B00.7060301@solarflare.com>
 <20160506.153829.1292994792261109577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:60888 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751699AbcEIMA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 08:00:26 -0400
In-Reply-To: <20160506.153829.1292994792261109577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/16 20:38, David Miller wrote:
> From: Edward Cree <ecree@solarflare.com>
> Date: Wed, 4 May 2016 18:01:52 +0100
>
>> These settings autoconfigure the number of RSS channels to match the number of
>> CPUs present.
>>
>> Signed-off-by: Edward Cree <ecree@solarflare.com>
> I can't believe I allowed this 'rss_cpus' thing into the tree to begin with.
>
> It's completely wrong and is exactly the kind of thing we are trying
> to actively avoid in network drivers.
Fair enough.  Should I resubmit patch 2/2 or is that one awful too?

-Ed
