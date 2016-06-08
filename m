From: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Wed, 8 Jun 2016 09:54:24 +0200
Message-ID: <5757CF30.2020603@gmx.de>
References: <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm> <5740E82F.8040903@gmx.de>
 <20160522091742.GA8681@debian-dorm> <57419853.9050701@gmx.de>
 <20160522223659.GB5086@electric-eye.fr.zoreil.com> <5743A9DD.8010202@gmx.de>
 <5744EA24.7060806@gmx.de> <20160528064348.GA19649@debian-dorm>
 <574CB382.7030102@gmx.de> <20160605140259.GA19512@debian-dorm>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, al.kochet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160605140259.GA19512@debian-dorm>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi Shuyu,

On 05.06.2016 16:02, Shuyu Wei wrote:
> Hi Lino,
> Sorry for my late reply. I retested the previous patch, it did have
> the same issue. However it seems that the possibility of stuck is lower
> (just my instinct, no evidence).
> 

Thank you for the feedback. It is hard to guess what is still going wrong.
But if you - as I assume - dont see this issue with the original code (as it is
in net-next) there is still something wrong with the changes we made. So we
probably should leave the code as it is for now.

Regards,
Lino  
