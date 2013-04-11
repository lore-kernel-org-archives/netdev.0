From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: Add GRO support
Date: Thu, 11 Apr 2013 20:07:16 +0200
Message-ID: <5166FBD4.5020508@gmail.com>
References: <1365684023-9967-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1365702955.7355.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 Soeren Moch <smoch@web.de>, Paul Mackerras <paulus@samba.org>,
 linux-arm-kernel@lists.infradead.org, Dale Farnsworth <dale@farnsworth.org>,
 netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 Florian Fainelli <florian@openwrt.org>,
 Lennert Buytenhek <buytenh@wantstofly.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1365702955.7355.5.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 04/11/2013 07:55 PM, Ben Hutchings wrote:
> On Thu, 2013-04-11 at 14:40 +0200, Sebastian Hesselbarth wrote:
>> This patch adds GRO support to mv643xx_eth by making it invoke
>> napi_gro_receive instead of netif_receive_skb.
>
> The inet_lro support should be removed at the same time; inet_lro is now
> deprecated and there should be no need to keep both of them.

Ben,

I agree on removing it asap, but I also like to see GRO support
in. Maybe, we postpone lro removal just a little bit. I have just
started to look at mv643xx_eth and remember Marvell Orion SoCs are
not the only platform using it. I haven't heard a single word from
ppc guys, yet.

Willy just posted an experimental patch to remove lro. I'll have
a look at it and test it out on Dove.

Sebastian
