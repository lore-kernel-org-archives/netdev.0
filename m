From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/3] net: Add table id from route lookup to
 route response
Date: Wed, 2 Sep 2015 22:18:12 +0200
Message-ID: <20150902201812.GB25648@pox.localdomain>
References: <1441212034-37464-1-git-send-email-dsa@cumulusnetworks.com>
 <1441212034-37464-3-git-send-email-dsa@cumulusnetworks.com>
 <20150902184346.GB20527@pox.localdomain>
 <20150902.114914.1705777375118723461.davem@davemloft.net>
 <55E74546.4070501@cumulusnetworks.com>
 <20150902190836.GD20527@pox.localdomain>
 <20150902194326.GZ504@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33833 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbbIBUSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 16:18:15 -0400
Received: by wicfx3 with SMTP id fx3so29264107wic.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 13:18:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150902194326.GZ504@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/15 at 03:43pm, Andy Gospodarek wrote:
> On Wed, Sep 02, 2015 at 09:08:36PM +0200, Thomas Graf wrote:
> > This behaviour comes back from when we still had the IPv4 routing cache
> > which was flat.
> 
> So before the routing cache was removed, was the response always
> RTA_TABLE_MAIN since there was no way to indicate which table may have
> route if it came from the cache?

Yes, from that perspective, get and list are very different in
behaviour. Again, I'm not against including this information
but we can't break compatibility.
