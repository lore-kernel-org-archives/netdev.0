From: kuznet@ms2.inr.ac.ru
Subject: Re: IFF_NOARP & broadcasting
Date: Wed, 24 Jul 2002 20:52:55 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207241652.UAA19057@sex.inr.ac.ru>
References: <20020724190421.A2449@karlis>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: karlis@mt.lv (Karlis Peisenieks)
In-Reply-To: <20020724190421.A2449@karlis> from "Karlis Peisenieks" at Jul 24, 2 08:15:01 pm
List-Id: netdev.vger.kernel.org

Hello!

> Is there any serious reason why when device has IFF_NOARP set, devices ll
> address is used as destination address even for broadcasts (and even when
> devices broadcast address is valid)?

No reasons, I think. Instead of that your patch, it may be better just 
exchange order of tests. As I remember, ll addr is initialized
to dev_addr for NOARP just to get a valid unicast address as destination
for eth_type_trans() to work correctly.


> Currently it is impossible to send out correct broadcast over ethernet
> when IFF_NOARP is set.

No, it is surely not impossible. f.e.

ip neigh add 255.255.255.255 dev dummy0 lladdr ff:ff:ff:ff:ff:ff

works.

Alexey
