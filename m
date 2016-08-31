From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/3] net: dsa: mv88e6xxx: add MDB support
Date: Wed, 31 Aug 2016 16:56:04 +0200
Message-ID: <20160831145604.GF15078@lunn.ch>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
 <20160829203246.18811-4-vivien.didelot@savoirfairelinux.com>
 <20160831135719.GC15078@lunn.ch>
 <874m618095.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <874m618095.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Do you mean the something like this?
> 
>     if (obj->id == SWITCHDEV_OBJ_ID_PORT_FDB) {
>         ...
>     } else if (obj->id == SWITCHDEV_OBJ_ID_PORT_MDB) {
>         ...
>     } else {
>         return -EOPNOTSUPP;
>     }

Hi Vivien

The -ENONOTSUPP is even better. I was not going as far as that.
 
> No the signatures are differentes. See _fdb vs. _mdb.

Ah, missed that. Then two functions are O.K. I don't think we should
consolidate it in the DSA layer.

	    Andrew

	    
