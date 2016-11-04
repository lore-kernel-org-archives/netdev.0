From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH net-next 1/5] ethtool: (uapi) Add ETHTOOL_PHY_GTUNABLE
 and ETHTOOL_PHY_STUNABLE
Date: Fri, 4 Nov 2016 13:18:41 +0100
Message-ID: <20161104121841.GA5676@microsemi.com>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
 <1478255742-25693-2-git-send-email-allan.nielsen@microsemi.com>
 <20161104120343.GI13959@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <cphealy@gmail.com>,
        <robh@kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0071.outbound.protection.outlook.com ([104.47.36.71]:41766
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753178AbcKDMSt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 08:18:49 -0400
Content-Disposition: inline
In-Reply-To: <20161104120343.GI13959@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 04/11/16 13:03, Andrew Lunn wrote:
> On Fri, Nov 04, 2016 at 11:35:38AM +0100, Allan W. Nielsen wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > Defines a generic API to get/set phy tunables. The API is using the
> > existing ethtool_tunable/tunable_type_id types which is already being used
> > for mac level tunables.
> >
> > Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> > Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
> > ---
> >  include/uapi/linux/ethtool.h | 7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> > index 8e54723..fd0bd36 100644
> > --- a/include/uapi/linux/ethtool.h
> > +++ b/include/uapi/linux/ethtool.h
> > @@ -248,6 +248,10 @@ struct ethtool_tunable {
> >       void    *data[0];
> >  };
> >
> > +enum phy_tunable_id {
> > +     ETHTOOL_PHY_ID_UNSPEC,
> > +};
> 
> Do you have any idea what this is for? A grep for
> ETHTOOL_TUNABLE_UNSPEC does not turn up anything.
It is not used...

It was "just" to mimic how "tunable_type_id/ETHTOOL_TUNABLE_UNSPEC" (and other)
is done.

The thinking was that we did not want an "ID" of zero do to anything - because
that could mean the programmer had forgot to set the field...

I have on strong feelings about this, please let us know if you would like this
done in an other way.

/Allan
