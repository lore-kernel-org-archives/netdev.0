From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] net: track link status of ipv6 nexthops
Date: Wed, 12 Aug 2015 17:44:32 -0400
Message-ID: <20150812214431.GY504@gospo.home.greyhouse.net>
References: <1438875754-28025-1-git-send-email-gospo@cumulusnetworks.com>
 <20150810.105400.1277861088010551746.davem@davemloft.net>
 <20150810184651.GL504@gospo.home.greyhouse.net>
 <20150812.143226.1427684779292104798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:33494 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbHLVof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:44:35 -0400
Received: by qkfj126 with SMTP id j126so9977168qkf.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 14:44:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150812.143226.1427684779292104798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2015 at 02:32:26PM -0700, David Miller wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Mon, 10 Aug 2015 14:46:52 -0400
> 
> > I went this way as the idea of storing this info in a flags structure
> > for 2 reasons:
> > 
> > - This idea or marking on link status changes and checking for that mark
> >   during forwarding was done what was suggested by Alex et al for the
> >   ipv4 code and I wanted to keep the overall design similar.
> > 
> > - New flags will likely be needed when switchdev support is added for
> >   ipv6 routes so going ahead and mirroring the RTNH_F* flags in the the
> >   ipv6 code seemed reasonable.
> > 
> > I would actually be fine with what you proposed (it is closer to the
> > first implementation), so if my justification above does not change your
> > mind, let me know and I'll post a v2 that does not add rt6i_nhflags and
> > simply checks netif_carrier_ok() rather than RTNH_F_LINKDOWN.
> 
> Ok fair enough, if we'll need more flags later then so be it.
> 
> Andy, please resubmit this series, I'll apply it.

Thanks, Dave.  Will do.
