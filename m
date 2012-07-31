From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wlcore: might_sleep operation in interrupt handler
Date: Tue, 31 Jul 2012 22:14:58 +0200
Message-ID: <1343765698.4474.10.camel@jlt3.sipsolutions.net>
References: <CADKZ3FKDw78ac9JPXJuw0s7Mqg1RrVfonbjXZ6zHmtwF2i5HoQ@mail.gmail.com>
	 (sfid-20120731_202836_974056_A601A727)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Luciano Coelho <coelho@ti.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Eliad Peller <eliad@wizery.com>,
	Arik Nemtsov <arik@wizery.com>, Eyal Shapira <eyal@wizery.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: Denis Yefremov <yefremov.denis@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADKZ3FKDw78ac9JPXJuw0s7Mqg1RrVfonbjXZ6zHmtwF2i5HoQ@mail.gmail.com> (sfid-20120731_202836_974056_A601A727)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-31 at 22:28 +0400, Denis Yefremov wrote:
> Interrupt handler wlcore_irq in wlcore/main.c file
> invokes mutex_lock that is might sleep operation.

> int __devinit wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
> {
> ...
>         ret = request_threaded_irq(wl->irq, wl12xx_hardirq, wlcore_irq,
>                                    irqflags,
>                                    pdev->name, wl);

Yes, umm, why do you think they're using a *threaded* IRQ? :-)

johannes
