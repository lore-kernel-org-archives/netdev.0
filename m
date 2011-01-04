From: jamal <hadi@cyberus.ca>
Subject: Re: [net-next-2.6 PATCH v4 1/2] net: implement mechanism for HW
 based QOS
Date: Tue, 04 Jan 2011 07:32:19 -0500
Message-ID: <1294144339.4927.79.camel@mojatatu>
References: <20110104030553.13187.69135.stgit@jf-dev1-dcblab>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jarkao2@gmail.com, shemminger@vyatta.com,
	tgraf@infradead.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:32869 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab1ADMcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 07:32:17 -0500
Received: by vws16 with SMTP id 16so6038579vws.19
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 04:32:17 -0800 (PST)
In-Reply-To: <20110104030553.13187.69135.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-03 at 19:05 -0800, John Fastabend wrote:
[..]

> To steer the skb we mask out the lower 4 bits of the priority
> and allow the hardware to configure upto 15 distinct classes
> of traffic. This is expected to be sufficient for most applications
> at any rate it is more then the 8021Q spec designates and is
> equal to the number of prio bands currently implemented in
> the default qdisc.

This seems very hardware specific.
i.e may be true for 8021q (or like 8021q) type hardware and therefore
your qdisc. 
There are people with hardware that has thousands of hardware
flow queues (or at least give impressions as such). Maybe a naming
convention prefixed with 8021Q would be nicer or moving it into
your qdisc infrastructure and export it so drivers needing it can.

cheers,
jamal

