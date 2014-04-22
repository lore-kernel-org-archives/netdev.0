From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/3] 6lowpan: add helper to get 6lowpan namespace
Date: Tue, 22 Apr 2014 11:44:46 +0200
Message-ID: <1398159886.4211.1.camel@jlt4.sipsolutions.net>
References: <1397784176-15809-1-git-send-email-mcgrof@do-not-panic.com>
	 <1397784176-15809-2-git-send-email-mcgrof@do-not-panic.com>
	 (sfid-20140418_032412_117495_4585013B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	backports@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@suse.com>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397784176-15809-2-git-send-email-mcgrof@do-not-panic.com> (sfid-20140418_032412_117495_4585013B)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-04-17 at 18:22 -0700, Luis R. Rodriguez wrote:

> +#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
> [...]
> +#else
> +static inline struct netns_ieee802154_lowpan *
> +net_ieee802154_lowpan(struct net *net)
> +{
> +	return NULL;
> +}
> +#endif

Why would that be needed? If nobody compiles 802.15.4 then it seems
nothing should reference it?

johannes
