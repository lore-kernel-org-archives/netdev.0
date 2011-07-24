From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2011-07-22
Date: Sun, 24 Jul 2011 03:09:49 -0700 (PDT)
Message-ID: <20110724.030949.1727841105144911931.davem@davemloft.net>
References: <20110722222308.GA3048@tuxdriver.com>
	<20110722.171635.1154932336401179368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110722.171635.1154932336401179368.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Fri, 22 Jul 2011 17:16:35 -0700 (PDT)

> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Fri, 22 Jul 2011 18:23:09 -0400
>=20
>> Here is the last big pull request of new wireless bits intended
>> for 3.1.  This includes the usual big batch of updates to iwlagn,
>> a number of updates to ath9k, mwifiex, carl9170, libertas, and other
>> drivers, and soem updates to mac80211 and cfg80211 from Johannes.
>> The most noteworth bits are most of the final push from Rafa=A9=A9 f=
or
>> supporting current Broadcom wireless hardware in b43.
>>=20
>> Please let me know if there are problems!
>=20
> A little late to be submitting this since the merge window is
> already open, but I pulled anyways.
>=20
> Thanks!

Please fix this build regression, the suspend/resume ops are only
available when CONFIG_PM is defined.

drivers/net/wireless/iwlwifi/iwl-agn.c:3464: error: unknown field 'susp=
end' specified in initializer
drivers/net/wireless/iwlwifi/iwl-agn.c:3464: warning: initialization fr=
om incompatible pointer type
drivers/net/wireless/iwlwifi/iwl-agn.c:3465: error: unknown field 'resu=
me' specified in initializer
drivers/net/wireless/iwlwifi/iwl-agn.c:3465: warning: initialization fr=
om incompatible pointer type
=20
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
