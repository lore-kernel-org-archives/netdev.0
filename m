From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] cfg80211/nl80211: add wifi tx power mode switching
 support
Date: Wed, 11 May 2016 09:21:31 +0200
Message-ID: <1462951291.2869.4.camel@sipsolutions.net>
References: <1462430663-9448-1-git-send-email-wnhuang@chromium.org>
	 (sfid-20160505_084446_369647_C7B8DEBC)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sameer Nanda <snanda-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Todd Broch <tbroch-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux-Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462430663-9448-1-git-send-email-wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> (sfid-20160505_084446_369647_C7B8DEBC)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-05-05 at 14:44 +0800, Wei-Ning Huang wrote:
> Recent new hardware has the ability to switch between tablet mode and
> clamshell mode. To optimize WiFi performance, we want to be able to
> use different power table between modes. This patch adds a new
> netlink message type and cfg80211_ops function to allow userspace to
> trigger a power mode switch for a given wireless interface.

I'm not a fan of this at all. Too much magic.

FWIW, we implemented something similar, currently with vendor commands,
that simply allows to set the TX power in a more controlled fashion,
i.e. allows setting TX power per band/channel range. For our device
it's only 2.4 GHz vs. 5.2 GHz, but I can imagine that you might want to
split it a bit further, so perhaps we need to advertise those ranges
somehow.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
