From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCHv3 net-next 00/12] net: mvpp2: misc improvements and
 preparation patches
Date: Thu, 9 Feb 2017 09:55:34 +0000
Message-ID: <20170209095534.GB27312@n2100.armlinux.org.uk>
References: <1486050701-27899-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
 Hanna Hawa <hannah@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1486050701-27899-1-git-send-email-thomas.petazzoni@free-electrons.com>
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

On Thu, Feb 02, 2017 at 04:51:29PM +0100, Thomas Petazzoni wrote:
> David,
> 
> This series contains a number of misc improvements and preparation
> patches for an upcoming series that adds support for the new PPv2.2
> network controller to the mvpp2 driver.
> 
> Sorry for the long delay since v2, I was on
> vacation/conference/training in January, and therefore wasn't able to
> resend a new version earlier. Upcoming versions should arrive much
> faster, if there are further comments on this series.
> 
> The most significant improvements are:
> 
>  - Switching to using build_skb(), which is necessary for the upcoming
>    PPv2.2 support, but anyway a good improvement to the current mvpp2
>    driver (supporting PPv2.1).
> 
>  - Making the driver build on 64-bit platforms.
> 
> Changes since v2:
> 
>  - Fix remaining 64-bit build warning, reported by David Miller.
> 
>  - Adjust how bit mask related definitions are done in "net: mvpp2:
>    simplify MVPP2_PRS_RI_* definitions" according to Russell King
>    suggestions.
> 
>  - Add a patch "net: mvpp2: remove useless arguments in
>    mvpp2_rx_{pkts,time}_coal_set", suggested by Russell King.
> 
>  - Rework mvpp2_rx_time_coal_set() implementation to avoid overflows
>    and rounding errors. I've used the implementation suggested by
>    Russell King.
> 
> Changes since v1:
> 
>  - This series is split as a separate series from the larger patch set
>    adding support for PPv2.2 in the mvpp2 driver, as requested by
>    David Miller.
> 
>  - Rebased on top of v4.10-rc1.

For the whole series:

Acked-by: Russell King <rmk+kernel@armlinux.org.uk>

Thanks.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
