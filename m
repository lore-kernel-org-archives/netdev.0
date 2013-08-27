From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next] qdisc: allow setting default queuing discipline
Date: Tue, 27 Aug 2013 16:22:52 -0700
Message-ID: <521D34CC.205@candelatech.com>
References: <20130827161908.26062336@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43316 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430Ab3H0XXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 19:23:00 -0400
In-Reply-To: <20130827161908.26062336@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2013 04:19 PM, Stephen Hemminger wrote:
> By default, the pfifo_fast queue discipline has been used by default
> for all devices. But we have better choices now.
>
> This patch allow setting the default queueing discipline with sysctl.
> This allows easy use of better queueing disciplines on all devices
> without having to use tc qdisc scripts. It is intended to allow
> an easy path for distributions to make fq_codel or sfq the default
> qdisc.
>
> This patch also makes pfifo_fast more of a first class qdisc, since
> it is now possible to manually override the default and explicitly
> use pfifo_fast. The behavior for systems who do not use the sysctl
> is unchanged, they still get pfifo_fast
>
> Also removes leftover random # in sysctl net core.

> +CoDel (codel) or fair queue CoDel (fq_codel). Dont' use queuing disciplines

nit: Don't has typo above....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
