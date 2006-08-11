From: David Miller <davem@davemloft.net>
Subject: Re: [NET 02/06]: Introduce RTA_TABLE/FRA_TABLE attributes
Date: Fri, 11 Aug 2006 00:33:56 -0700 (PDT)
Message-ID: <20060811.003356.20894129.davem@davemloft.net>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
	<20060810193000.14867.49807.sendpatchset@localhost.localdomain>
	<44DC2B93.3000605@tls.msk.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11448
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161146AbWHKHd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 03:33:57 -0400
To: mjt@tls.msk.ru
In-Reply-To: <44DC2B93.3000605@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Tokarev <mjt@tls.msk.ru>
Date: Fri, 11 Aug 2006 11:02:43 +0400

> Patrick McHardy wrote:
> > --- a/include/linux/rtnetlink.h
> > +++ b/include/linux/rtnetlink.h
> 
> > +static inline u32 rtm_get_table(struct rtattr **rta, u8 table)
> > +{
> > +	return RTA_GET_U32(rta[RTA_TABLE-1]);
> > +rtattr_failure:
> > +	return table;
> > +}
> > +
> 
> What's that ?  ;)

The RTA_GET_U32 macro internally branches to rtattr_failure.
