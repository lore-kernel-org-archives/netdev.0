From: Stefan Monnier <monnier-CRDzTM1onBSWkKpYnGOUKg@public.gmane.org>
Subject: Re: [RFC v2] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 20:59:03 -0500
Message-ID: <jwvy6m4bnqp.fsf-monnier+gmane.linux.kernel.wireless.general@gnu.org>
References: <1258465585.3682.7.camel@johannes.local>
	<1258490898.21197.42.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> A number of people have tried to add a wireless interface
> (in managed mode) to a bridge and then complained that it
> doesn't work. It cannot work, however, because in 802.11
[...]
> To avoid such mistakes in the future, disallow adding a
> wireless interface to a bridge.

As someone who's been bitten by this, I fully support this change.
Still, it makes me wonder: my broadcom-based home-router using the wl.o
driver can be set in "client bridge" mode.  How does it work?


        Stefan

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
