From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable-4.0] cdc_ncm: Fix tx_bytes statistics
Date: Fri, 22 May 2015 14:34:21 -0400 (EDT)
Message-ID: <20150522.143421.442426385899149301.davem@davemloft.net>
References: <1432293322-11928-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, me-J2duszcpOy900TDglC2tyg@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org,
	ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432293322-11928-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Fri, 22 May 2015 13:15:22 +0200

> The tx_curr_frame_payload field is u32. When we try to calculate a
> small negative delta based on it, we end up with a positive integer
> close to 2^32 instead.  So the tx_bytes pointer increases by about
> 2^32 for every transmitted frame.
>=20
> Fix by calculating the delta as a signed long.
>=20
> Cc: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
> Reported-by: Florian Bruhin <me-J2duszcpOy900TDglC2tyg@public.gmane.org>
> Fixes: 7a1e890e2168 ("usbnet: Fix tx_bytes statistic running backward=
 in cdc_ncm")
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied and queued up for -stable.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
