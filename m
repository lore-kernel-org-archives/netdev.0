From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [RFC] iwmc3200top: remove driver for unavailable hardware
Date: Tue, 26 Jun 2012 21:21:34 +0000
Message-ID: <3A78FAA0EC814D4B8ECC99B3AB32B3320812EBC9@fmsmsx110.amr.corp.intel.com>
References: <1340740397-18119-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Ortiz, Samuel" <samuel.ortiz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1340740397-18119-1-git-send-email-linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi  John

> From: John W. Linville [mailto:linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org]
> Subject: [RFC] iwmc3200top: remove driver for unavailable hardware
> 
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> 
> This hardware never became available to normal humans.  Leaving this
> driver imposes unwelcome maintenance costs for no clear benefit.
> 
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> ---
> Can't remove this just yet, as it is selected by the i2400m wimax
> driver.  The 3200 bits of that driver seem a bit intertwined with the
> rest of the driver.
> 
> Are there any other SDIO parts for i2400m?  Does anyone have any other
> guidance on how I can safely make i2400m be independent of iwmc3200
> support?

It should be pretty straight forward: remove the dependency. In fact, you
are very right--all the sdio code should be removed, as there are no SDIO
parts in the market, to the best of my knowledge.

Yank anything hitting a grep on sdio in i2400m/ (*sdio*) and the Makefile
entries, as well as the Kconfig. That should take care of it.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
