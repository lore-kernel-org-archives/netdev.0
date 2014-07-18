From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v9 3/9] net: nl802154 - make add_iface take
 name assign type
Date: Fri, 18 Jul 2014 08:29:15 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D172786CD@AcuExch.aculab.com>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
	<1405584370-30054-4-git-send-email-teg@jklm.no>
 <20140717.161931.283488873926282207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>
To: 'David Miller' <davem@davemloft.net>, "teg@jklm.no" <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140717.161931.283488873926282207.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller
> From: Tom Gundersen <teg@jklm.no>
> Date: Thu, 17 Jul 2014 10:06:04 +0200
> 
> > @@ -192,8 +193,10 @@ int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info)
> >  		if (devname[nla_len(info->attrs[IEEE802154_ATTR_DEV_NAME]) - 1]
> >  				!= '\0')
> >  			return -EINVAL; /* phy name should be null-terminated */
> > +		name_assign_type = NET_NAME_USER;
> >  	} else  {
> >  		devname = "wpan%d";
> > +		name_assign_type = NET_NAME_ENUM;
> >  	}
> >
> >  	if (strlen(devname) >= IFNAMSIZ)
> 
> Just wondering what should happen if "%d" appears in a user provided name.
> 
> That would seem to be both USER and ENUM.

Is a training %d detected by special code?
Or is the string used as a printf format?
If the latter is true what happens if the user provides foo%s

	David
