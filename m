From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NET: ASSERT_RTNL in __dev_set_promiscuity makes debug warning
Date: Tue, 04 Dec 2007 23:26:54 +0100
Message-ID: <4755D42E.7050602@gmail.com>
References: <000001c8365a$e0e500c0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Linux Kernel Mailing List' <linux-kernel@vger.kernel.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755210AbXLDWXp@vger.kernel.org>
In-Reply-To: <000001c8365a$e0e500c0$9c94fea9@jason>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joonwoo Park wrote, On 12/04/2007 10:48 AM:

> Hi,
> dev_set_rx_mode calls __dev_set_rx_mode with softirq disabled (by netif_tx_lock_bh)
> therefore __dev_set_promiscuity can be called with softirq disabled.
> It will cause in_interrupt() to return true and ASSERT_RTNL warning.
> Is there a good solution to fix it besides blowing ASSERT_RTNL up?


Fixing ASSERT_RTNL up?!

But, IMHO, blowing ASSERT_RTNL up in a few places shouldn't be much
worse. After all, how long such a debugging code should be kept. It
seems, at least sometimes we should be a bit more confident of how
it's called.

Regards,
Jarek P.
