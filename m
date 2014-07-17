From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 0/2] net: davinci_mdio: reuse for keystone2 arch
Date: Wed, 16 Jul 2014 23:33:47 -0700 (PDT)
Message-ID: <20140716.233347.1283806216031286454.davem@davemloft.net>
References: <1405512783-20307-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, santosh.shilimkar-l0cyMroinI0@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org, mugunthanvnm-l0cyMroinI0@public.gmane.org
To: grygorii.strashko-l0cyMroinI0@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405512783-20307-1-git-send-email-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Date: Wed, 16 Jul 2014 15:13:01 +0300

> The similar MDIO HW blocks is used by keystone 2 SoCs as
> in Davinci SoCs:
> - one in Gigabit Ethernet (GbE) Switch Subsystem
>   See http://www.ti.com/lit/ug/sprugv9d/sprugv9d.pdf
> - one in 10 Gigabit Ethernet Subsystem
>   See http://www.ti.com/lit/ug/spruhj5/spruhj5.pdf
> 
> Hence, reuse Davinci MDIO driver for Keystone 2 and
> enable TI networking for Keystone 2 devices.
> 
> Also, as part of this series, enable PHY's creation from DT, because
> Keystone 2 supports DT boot mode only.
> 
> Changes in v2:
> - review comments applied. 
>   Keystone 2 compatibility string changed to "ti,keystone_mdio".

Series applied to net-next, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
