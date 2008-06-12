From: Luis Carlos Cobo <luisca-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] Do not activate promiscuous mode on wlan interfaces for
	bridging.
Date: Thu, 12 Jun 2008 11:53:35 -0700
Message-ID: <1213296815.6615.24.camel@localhost>
References: <1213232760.6645.24.camel@localhost>
	 (sfid-20080612_030607_332834_1EFDE126)  <1213255570.3871.8.camel@johannes.berg>
	 <1213294793.6615.16.camel@localhost>
	 (sfid-20080612_202000_504292_98E93460)  <1213294852.3730.31.camel@johannes.berg>
	 <1213295643.6615.20.camel@localhost>
	 (sfid-20080612_203408_119945_EA437275)  <1213296250.3730.33.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	j@w1.fi, bridge-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1213296250.3730.33.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-06-12 at 20:44 +0200, Johannes Berg wrote:
> But in response to what mac80211 command are you sending the promisc
> mode to the hw?

In the function associated to .configure_filter (struct ieee80211_ops)
in the driver, when (*new_flags & (FIF_PROMISC_IN_BSS))

-- 
Luis Carlos Cobo Rus       GnuPG ID: 44019B60
cozybit Inc.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
