From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull-request: mac80211 2015-11-26
Date: Wed, 02 Dec 2015 10:46:50 +0100
Message-ID: <1449049610.2449.3.camel@sipsolutions.net>
References: <1448552352.2167.14.camel@sipsolutions.net>
	 (sfid-20151126_163919_664516_CC0F7608)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1448552352.2167.14.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> (sfid-20151126_163919_664516_CC0F7608)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

> ----------------------------------------------------------------
> A small set of fixes for 4.4:
> =C2=A0* remove NL80211_FEATURE_FULL_AP_CLIENT_STATE again, it
> =C2=A0=C2=A0=C2=A0was broken and needs more work, we'll enable it for=
 4.5
> =C2=A0* fix call_rcu() induced use-after-reset/free in mesh
> =C2=A0=C2=A0=C2=A0(that was suddenly causing issues in certain tests)
> =C2=A0* always request block-ack window size 64 as we found
> =C2=A0=C2=A0=C2=A0some APs will otherwise crash (really ...)
> =C2=A0* fix P2P-Device teardown sequence to avoid restarting
> =C2=A0=C2=A0=C2=A0with uninitialized data

I've got two more fairly important changes - one for regulatory issues
and one for an uninitialized variable that was leading to fairly
obscure bugs - do you prefer I wait, or send a new pull request
covering this one plus the two new fixes?

Thanks,
johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
