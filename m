From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] fixed_phy: pass 'irq' to fixed_phy_add()
Date: Thu, 03 Sep 2015 13:23:49 -0700
Message-ID: <55E8AC55.9080105@gmail.com>
References: <3613326.r1qXWqo08b@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3613326.r1qXWqo08b@wasted.cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/15 13:22, Sergei Shtylyov wrote:
> I've noticed  that fixed_phy_register() ignores its 'irq' parameter instead of
> passing it to fixed_phy_add(). Luckily, fixed_phy_register()  seems to  always
> be  called with PHY_POLL  for 'irq'... :-)

So not critical for -stable, good!

> 
> Fixes: a75951217472 ("net: phy: extend fixed driver with fixed_phy_register()")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
