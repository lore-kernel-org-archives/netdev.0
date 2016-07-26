From: Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Tue, 26 Jul 2016 12:41:47 +0900
Message-ID: <2a5bb9ed-c691-a053-2892-4f772d24330f@gmail.com>
References: <20160713200755.26839-1-yanivma@ti.com>
 <40a34537-486e-a466-5a7e-e253f19d81c3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <40a34537-486e-a466-5a7e-e253f19d81c3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2016=E5=B9=B407=E6=9C=8822=E6=97=A5 14:26, Masashi Honma wrote:
 > On 2016=E5=B9=B407=E6=9C=8814=E6=97=A5 05:07, Yaniv Machani wrote:
 >> +
 >> +    /* if channel width is 20MHz - configure HT capab accordingly*=
/
 >> +    if (sdata->vif.bss_conf.chandef.width =3D=3D NL80211_CHAN_WIDT=
H_20) {
 >> +        cap &=3D ~IEEE80211_HT_CAP_SUP_WIDTH_20_40;
 >> +        cap &=3D ~IEEE80211_HT_CAP_DSSSCCK40;
 >> +    }
 >
 > I have tested this part of your patch and this works for me.
 >
 > Previouly, "Supported Channel Width Set bit" in HT Capabilities elem=
ent
 > was 1 even though disable_ht40=3D1 existed in wpa_supplicant.conf.
 > After appllication of patch, the bit was 0.
 >
 >

# I retransmit this because of mail delivery errors.

I forgot to mention I have used this patch to test.
http://lists.infradead.org/pipermail/hostap/2016-July/036029.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
