From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ieee802154: fix variable declaration and
 initializer
Date: Tue, 18 Mar 2014 22:11:25 -0700
Message-ID: <1395205885.8649.35.camel@joe-AO722>
References: <1395199198-14310-1-git-send-email-sakiwit@gmail.com>
	 <1395199941.9114.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1395200557.8649.20.camel@joe-AO722>
	 <1395203754.9114.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jean Sacren <sakiwit@gmail.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0238.hostedemail.com ([216.40.44.238]:54502 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750779AbaCSFL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 01:11:28 -0400
In-Reply-To: <1395203754.9114.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-18 at 21:35 -0700, Eric Dumazet wrote:
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

No, that's not obvious at all actually.

I would have used "Change the type to bool and remove
the now unnecessary !!" in the changelog to link Jean's
points 1 and 2, but your statement and the code and
commit log changes proposed by Jean don't match.

The type _did_ change as described in point 1.

> Stating it is a 'fix' is quite a false statement, I see no fix at all,
> maybe a cleanup, but I am not really convinced.

Perhaps "fix" is a more flexible word than you imagine.
Perhaps this a code style "fix" without logic change.

<shrug>  I'm very ambivalent about it too.
