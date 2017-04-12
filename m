From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC 1/3] bpf/wireless: add wifimon program type
Date: Wed, 12 Apr 2017 21:47:44 +0200
Message-ID: <74C8B200-1552-497E-853B-33428E8E2FF3@holtmann.org>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170412110726.9689-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

> Add a new program type for wifi monitor interfaces. This program
> type can
> * access __sk_buff, but only skb->len
> * call bpf_skb_load_bytes()
> 
> The program type is only enabled when something selects the new
> Kconfig symbol WANT_BPF_WIFIMON, which will be done by mac80211
> in a follow-up patch.

we used to stay away from WIFI naming in the kernel. Any reasoning why this is used instead of WLAN now?

Regards

Marcel
