From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: track link status of ipv6 nexthops
Date: Wed, 12 Aug 2015 14:32:26 -0700 (PDT)
Message-ID: <20150812.143226.1427684779292104798.davem@davemloft.net>
References: <1438875754-28025-1-git-send-email-gospo@cumulusnetworks.com>
	<20150810.105400.1277861088010551746.davem@davemloft.net>
	<20150810184651.GL504@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60153 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbHLVc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:32:27 -0400
In-Reply-To: <20150810184651.GL504@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Mon, 10 Aug 2015 14:46:52 -0400

> I went this way as the idea of storing this info in a flags structure
> for 2 reasons:
> 
> - This idea or marking on link status changes and checking for that mark
>   during forwarding was done what was suggested by Alex et al for the
>   ipv4 code and I wanted to keep the overall design similar.
> 
> - New flags will likely be needed when switchdev support is added for
>   ipv6 routes so going ahead and mirroring the RTNH_F* flags in the the
>   ipv6 code seemed reasonable.
> 
> I would actually be fine with what you proposed (it is closer to the
> first implementation), so if my justification above does not change your
> mind, let me know and I'll post a v2 that does not add rt6i_nhflags and
> simply checks netif_carrier_ok() rather than RTNH_F_LINKDOWN.

Ok fair enough, if we'll need more flags later then so be it.

Andy, please resubmit this series, I'll apply it.

Thanks.
