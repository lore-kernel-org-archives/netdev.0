From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 01/10] net: Split core bits of dev_pick_tx into __dev_pick_tx
Date: Thu, 02 Aug 2012 08:45:25 -0700
Message-ID: <501AA095.60901@intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com> <20120630001618.29939.26996.stgit@gitlad.jf.intel.com> <1341619403.2923.42.camel@bwh-desktop.uk.solarflarecom.com> <CAL1qit_mpmVYQ3D4HQsii5LJ+Nu5=ftFWAWVnfPiDbmW5eWa0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, therbert@google.com, alexander.duyck@gmail.com
To: Ying Cai <ycai@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43737 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281Ab2HBPpi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 11:45:38 -0400
In-Reply-To: <CAL1qit_mpmVYQ3D4HQsii5LJ+Nu5=ftFWAWVnfPiDbmW5eWa0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2012 08:51 PM, Ying Cai wrote:
> I liked this patch too. It enabled Ethernet NIC drivers to use
> the __dev_pick_tx() in their ndo_select_queue() to use XPS. I have
> data showing XPS helps performances of bnx2x driver significantly.
>
> Acked-by: Ying Cai <ycai@ <mailto:jg1.han@samsung.com>google.com
> <http://google.com>>
This was an RFC so there is no need to ack it.

I will try to get these patches cleaned up and ready for submission. 
Hopefully I will have something to submit to net-next in the next couple
of weeks.

Thanks,

Alex
