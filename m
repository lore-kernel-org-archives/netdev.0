From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/4] mac80211: set NET_NAME_USER for user-space created
 ifs
Date: Thu, 27 Feb 2014 15:53:07 +0100
Message-ID: <1393512787.4648.1.camel@jlt4.sipsolutions.net>
References: <1393512434-1325-1-git-send-email-dh.herrmann@gmail.com>
	 <1393512434-1325-3-git-send-email-dh.herrmann@gmail.com>
	 (sfid-20140227_154844_921310_B406E62F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Tom Gundersen <teg@jklm.no>, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Herrmann <dh.herrmann@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393512434-1325-3-git-send-email-dh.herrmann@gmail.com> (sfid-20140227_154844_921310_B406E62F)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Given the premise of your patches,

> +++ b/net/mac80211/iface.c
> @@ -1620,6 +1620,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
>  					+ IEEE80211_ENCRYPT_HEADROOM;
>  		ndev->needed_tailroom = IEEE80211_ENCRYPT_TAILROOM;
>  
> +		ndev->name_assign_type = NET_NAME_USER;

this is wrong because we call this in main.c with a "wlan%d" argument
for the name, which gets expanded.

johannes
