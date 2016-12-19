From: Romain Perier <romain.perier@free-electrons.com>
Subject: Re: [PATCH 1/4] net: dsa: mv88e6xxx: Allow mv88e6xxx_smi_init() to be
 used at address 0x1
Date: Mon, 19 Dec 2016 15:56:34 +0100
Message-ID: <292d4f15-c58b-3565-26ec-98a025b6adb3@free-electrons.com>
References: <20161219141610.30934-1-romain.perier@free-electrons.com>
 <20161219141610.30934-2-romain.perier@free-electrons.com>
 <20161219143848.GA10048@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, Jason Cooper <jason@lakedaemon.net>,
 Pawel Moll <pawel.moll@arm.com>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Nadav Haklai <nadavh@marvell.com>, Rob Herring <robh+dt@kernel.org>,
 Kumar Gala <galak@codeaurora.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>,
 Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161219143848.GA10048@lunn.ch>
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

Hi Andrew,

Le 19/12/2016 =E0 15:38, Andrew Lunn a =E9crit :
> On Mon, Dec 19, 2016 at 03:16:06PM +0100, Romain Perier wrote:
>> Currently, the function mv88e6xxx_smi_init() returns -EINVAL if the bit
>> zero of sw_addr is 0x1. However, on some platforms, ethernet switches
>> are configured in Multi chip addressing mode and available at MDIO
>> address 0x1.
>
> Hi Romain
>
> What branch is this against? net-next?

Until last friday it was based onto next-20161216, I rebased onto the =

torvalds's tree this morning (so ~4.10-pre-rc1).

>
> Please see:
>
> https://www.spinics.net/lists/netdev/msg409156.html

Oh, it's already fixed, good. I did not see this patch :)

>
> It would be nicer to use Volodymyr, since it has been reviewed.


As the fix is already there, I will use it, sure.

Thanks,
Romain
