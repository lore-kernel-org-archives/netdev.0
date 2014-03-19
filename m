From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next] ieee802154: fix variable declaration and
 initializer
Date: Tue, 18 Mar 2014 22:31:54 -0600
Message-ID: <20140319043154.GA1448@mail.gmail.com>
References: <1395199198-14310-1-git-send-email-sakiwit@gmail.com>
 <1395199941.9114.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:45054 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259AbaCSEf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 00:35:27 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so8306333pbb.25
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 21:35:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1395199941.9114.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Mar 2014 20:32:21 -0700
>
> On Tue, 2014-03-18 at 21:19 -0600, Jean Sacren wrote:
> 
> > 2) Fix the initializer by deleting the double logical negation
> >    operators as they don't serve any purpose.
> > 
> ...
> >  
> >  static int phy_set_lbt(struct wpan_phy *phy, struct genl_info *info)
> >  {
> > -	u8 on = !!nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
> 
> You do realize !!(a) is not equivalent to (a) ?

I admire you for your knowledge and skill. With the double logical
negation operation hereof, I do know what I'm doing.

Thank you,

-- 
Jean Sacren
