From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ieee802154: fix variable declaration and
 initializer
Date: Tue, 18 Mar 2014 21:35:54 -0700
Message-ID: <1395203754.9114.54.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395199198-14310-1-git-send-email-sakiwit@gmail.com>
	 <1395199941.9114.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1395200557.8649.20.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jean Sacren <sakiwit@gmail.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:49221 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259AbaCSEf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 00:35:56 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so8070753pdi.19
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 21:35:55 -0700 (PDT)
In-Reply-To: <1395200557.8649.20.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-18 at 20:42 -0700, Joe Perches wrote:
> On Tue, 2014-03-18 at 20:32 -0700, Eric Dumazet wrote:
> > On Tue, 2014-03-18 at 21:19 -0600, Jean Sacren wrote:
> > 
> > > 2) Fix the initializer by deleting the double logical negation
> > >    operators as they don't serve any purpose.
> > > 
> > ...
> > >  
> > >  static int phy_set_lbt(struct wpan_phy *phy, struct genl_info *info)
> > >  {
> > > -	u8 on = !!nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
> > 
> > You do realize !!(a) is not equivalent to (a) ?
> 
> It is when the type it's assigned to also changes
> from u8 to bool.

I was referring to the changelog, obviously, see how I carefully
copy/pasted the relevant part ?

Stating it is a 'fix' is quite a false statement, I see no fix at all,
maybe a cleanup, but I am not really convinced.
