From: "Jean-Pierre Tosoni" <jp.tosoni-eYuUwLwYA0BQFI55V6+gNQ@public.gmane.org>
Subject: RE: [PATCH net-next] bridge: multicast to unicast
Date: Mon, 9 Jan 2017 09:36:55 +0100
Message-ID: <002f01d26a53$88c8da60$9a5a8f20$@acksys.fr>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue> <20170106191356.43740a26@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "'David S . Miller'" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "'Felix Fietkau'" <nbd-Vt+b4OUoWG0@public.gmane.org>
To: "'Stephen Hemminger'" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        "=?UTF-8?Q?'Linus_L=C3=BCssing'?=" <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170106191356.43740a26@xeon-e3>
Content-Language: fr
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Message d'origine-----
> De : linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:linux-wireless-
> owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] De la part de Stephen Hemminger
> Envoyé : samedi 7 janvier 2017 04:14
> À : Linus Lüssing
> Cc : netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; David S . Miller; bridge-cunTk1MwBs/ROKNJybVBZg@public.gmane.org
> foundation.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Felix Fietkau
> Objet : Re: [PATCH net-next] bridge: multicast to unicast
> 
> On Mon,  2 Jan 2017 20:32:14 +0100
> Linus Lüssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org> wrote:
> 
> > This feature is intended for interface types which have a more
> > reliable and/or efficient way to deliver unicast packets than
> > broadcast ones (e.g. wifi).
> 
> 
> Why is this not done in MAC80211 rather than  bridge?

OTOH mac80211 has more information to decide whether it is more economic to send one multicast or several unicast.
It depends on the bitrate of each station, number of stations and the (not necessarily slower) bitrate of multicasts.
