From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC patch] include/net/cfg80211.h: wiphy_<level> messages use
 dev_printk
Date: Thu, 19 Aug 2010 21:39:44 +0200
Message-ID: <1282246784.4507.14.camel@jlt3.sipsolutions.net>
References: <1282245848.6724.261.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282245848.6724.261.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-08-19 at 12:24 -0700, Joe Perches wrote:
> Adding device to the wiphy logging messages could be useful.
>  
>  #define wiphy_printk(level, wiphy, format, args...)		\
> -	printk(level "%s: " format, wiphy_name(wiphy), ##args)
> +	dev_printk(level, &wiphy->dev, "%s: " format, wiphy_name(wiphy), ##args)

what will that actually print?

johannes
