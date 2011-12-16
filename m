From: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: skb->priority usage in wireless frame classification
Date: Fri, 16 Dec 2011 09:45:33 +0100
Message-ID: <CAGXE3d_ouo4KzQA0-ysLz_RwcqoTc5Sg4V6BZZJP0TJewzNOxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[Adding netdev]

Maybe someone from the netdev people can shed some light on this.
We've got the following code in net/wireless/util.c for frame classific=
ation
(cfg80211_classify8021d):

/* skb->priority values from 256->263 are magic values to
* directly indicate a specific 802.1d priority. =A0This is used
* to allow 802.1d priority to be passed directly in from VLAN
* tags, etc.
*/
if (skb->priority >=3D 256 && skb->priority <=3D 263)
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return skb->priority - 256;

I was just thinking about making use of this for some internal mac80211
QoS handling. But is this code still valid? At least I haven't found an=
ything
in the 802.1q code :(

Thanks,
Helmut
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
