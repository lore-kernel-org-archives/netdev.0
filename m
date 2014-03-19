From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next] ieee802154: fix variable declaration and
 initializer
Date: Tue, 18 Mar 2014 22:56:34 -0600
Message-ID: <20140319045634.GB1448@mail.gmail.com>
References: <1395199198-14310-1-git-send-email-sakiwit@gmail.com>
 <1395199941.9114.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <1395200557.8649.20.camel@joe-AO722>
 <1395203754.9114.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:43841 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbaCSFAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 01:00:07 -0400
Received: by mail-pb0-f45.google.com with SMTP id uo5so8337785pbc.18
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 22:00:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1395203754.9114.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Mar 2014 21:35:54 -0700
>
> On Tue, 2014-03-18 at 20:42 -0700, Joe Perches wrote:
> > On Tue, 2014-03-18 at 20:32 -0700, Eric Dumazet wrote:
> > > On Tue, 2014-03-18 at 21:19 -0600, Jean Sacren wrote:
> > > 
> > > > 2) Fix the initializer by deleting the double logical negation
> > > >    operators as they don't serve any purpose.
> > > > 
> > > ...
> > > >  
> > > >  static int phy_set_lbt(struct wpan_phy *phy, struct genl_info *info)
> > > >  {
> > > > -	u8 on = !!nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
> > > 
> > > You do realize !!(a) is not equivalent to (a) ?
> > 
> > It is when the type it's assigned to also changes
> > from u8 to bool.
> 
> I was referring to the changelog, obviously, see how I carefully
> copy/pasted the relevant part ?
> 
> Stating it is a 'fix' is quite a false statement, I see no fix at all,
> maybe a cleanup, but I am not really convinced.

Stating it is a "fix" is not a false statement at all. !! falsely
changes the value to be int TWICE for nothing! Are you still not
convinced?

-- 
Jean Sacren
