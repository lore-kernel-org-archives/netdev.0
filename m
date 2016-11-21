From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v7 1/2] nl80211: multicast_to_unicast can be changed
 while IFF_UP
Date: Mon, 21 Nov 2016 13:50:52 +0100
Message-ID: <1479732652.8662.21.camel@sipsolutions.net>
References: <1477921260-24556-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        projekt-wlan-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org
To: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477921260-24556-1-git-send-email-michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-10-31 at 14:40 +0100, Michael Braun wrote:
> There is no need to prevent toggling multicast_to_unicast while
> interface is already up. This change simplifies reconfiguration
> from hostapd.

Applied. This check never should've been there anyway, if desired,
NEED_NETDEV_UP should've been used.

johannes
