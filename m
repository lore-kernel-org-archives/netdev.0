From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [patch 4/4] Configure out IGMP support
Date: Fri, 01 Aug 2008 20:41:55 +0100
Message-ID: <1217619715.3454.488.camel@pmac.infradead.org>
References: <20080731092703.661994657@free-electrons.com>
	 <20080731093221.565015353@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	michael@free-electrons.com, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20080731093221.565015353@free-electrons.com>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-07-31 at 11:27 +0200, Thomas Petazzoni wrote:
> This patchs adds the CONFIG_IGMP option which allows to remove support
> for the Internet Group Management Protocol, used in
> multicast. Multicast is not necessarly used by applications,
> particularly on embedded devices. As this is a size-reduction option,
> it depends on CONFIG_EMBEDDED. It allows to save ~10 kilobytes of
> kernel code/data:

The config option probably lives in net/Kconfig, not init/Kconfig.

And please could you make it clear how this interacts with IP_MULTICAST?

We already have a CONFIG_IP_MULTICAST option, for which the help text
says "For more people, it's safe to say N'. And I think it defaults to
that too. What more does CONFIG_IGMP remove? It's not made clear by the
help text.

-- 
dwmw2
