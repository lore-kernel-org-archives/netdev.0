From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: pull request: wireless-next 2011-11-28
Date: Tue, 29 Nov 2011 13:58:06 +0200
Message-ID: <4ED4C8CE.8030408@qca.qualcomm.com>
References: <20111128200221.GD2681@tuxdriver.com> <20111128.195516.37800643865997337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111128.195516.37800643865997337.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/29/2011 02:55 AM, David Miller wrote:

> Pulled, but please push back on the ath6kl guys, they seem to have
> this disease where they add tons of debugfs files

Sorry about that. I was under impression that there are no strict rules
for debugfs files and drivers can add them without too much worries, but
it seems I was wrong.

> for controlling things like QoS from userspace instead of creating
> and using generic configuration machanisms via netlink or similar
> that any other driver could support too.

Adding a generic QoS interface would take some time to implement and I
doubt that we (=ath6kl team) can do that anytime soon as our first
challange has been to get ath6kl working properly with cfg80211. That's
why we ended up having a debugfs interface for qos as our first step.

Kalle
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
