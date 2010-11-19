From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC][PATCH 0/5] RFS hardware acceleration (v2)
Date: Fri, 19 Nov 2010 13:16:46 -0800
Message-ID: <4CE6E93E.7000901@hp.com>
References: <1290192176.2671.38.camel@bwh-desktop> <1290194386.2671.59.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:20227 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755662Ab0KSVXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 16:23:55 -0500
In-Reply-To: <1290194386.2671.59.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> So, some preliminary benchmark results.
> 
> Tom said he was using 200 concurrent netperf TCP_RR tests, so I've done
> the same, using netperf 2.4.1 (a bit out of date, I know).

Not a huge deal for a basic TCP_RR test though.

<data snipped>

> So accelerated RFS gave a 6-13% improvement over software RFS in
> transaction rate for these various cases.

Do you have any data on frequency with which unpinned netperf processes migrated 
from one core to another?  Or PCIe utilization?

rick jones
