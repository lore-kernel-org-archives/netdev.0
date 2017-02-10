From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [net-next] ARM: orion: fix PHYLIB dependency
Date: Fri, 10 Feb 2017 09:42:21 -0800
Message-ID: <352146cc-845c-2860-44ca-7338eb53e260@gmail.com>
References: <20170209150834.1158193-1-arnd@arndb.de>
 <c6ab6498-8094-b23e-0b93-c3bf1c866992@gmail.com>
 <CAK8P3a2Yss8r0qoubg2C7Jp+0JE3Fx+igWHQOscR+SB6d+W_HA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Networking <netdev@vger.kernel.org>, Russell King <linux@armlinux.org.uk>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S . Miller" <davem@davemloft.net>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAK8P3a2Yss8r0qoubg2C7Jp+0JE3Fx+igWHQOscR+SB6d+W_HA@mail.gmail.com>
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

On 02/10/2017 12:20 AM, Arnd Bergmann wrote:
> On Thu, Feb 9, 2017 at 7:22 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 02/09/2017 07:08 AM, Arnd Bergmann wrote:
>> I disabled CONFIG_NETDEVICES to force CONFIG_PHY not to be set here, and
>> I was not able to reproduce this, what am I missing?
> 
> In the ARMv5 allmodconfig build, this fails because CONFIG_PHY=m, and
> we can't call into it. You could use IS_BUILTIN instead of IS_ENABLED in
> the header as a oneline workaround, but I think that would be more confusing
> to real users that try to use CONFIG_PHY=m without realizing why they lose
> access to their switch.

I see, this patch should also help fixing this:

http://patchwork.ozlabs.org/patch/726381/

-- 
Florian
