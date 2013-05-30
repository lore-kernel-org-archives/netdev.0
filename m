From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCHv3 RESEND 0/6] ARM: sunxi: Add support for A10 Ethernet
 controller
Date: Thu, 30 May 2013 10:11:29 +0200
Message-ID: <20130530081129.GF9799@lukather>
References: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com>
 <CACQ1gAgp6o8HqQcv=4cWoAZze3wtXHMX+g+7KvV-pnC2W5=iyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Emilio Lopez <emilio@elopez.com.ar>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com, Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	linux-arm-kernel@lists.infradead.org
To: Richard Genoud <richard.genoud@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACQ1gAgp6o8HqQcv=4cWoAZze3wtXHMX+g+7KvV-pnC2W5=iyg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On Wed, May 29, 2013 at 08:15:49PM +0200, Richard Genoud wrote:
> 2013/5/24 Maxime Ripard <maxime.ripard@free-electrons.com>:
> I tested it successfully on cubieboard 1GB, on top of kernel 3.10-rc3,
> nfsroot (debian wheezy)
> I also added in sun4i-a10-cubieboard.dts
> phy0: ethernet-phy@0 {
>  reg = <1>;
> },
> like Emilio suggested.
> 
> running an iperf, there's some good perfs !
> iperf -s
> ------------------------------------------------------------
> Server listening on TCP port 5001
> TCP window size: 85.3 KByte (default)
> ------------------------------------------------------------
> [  4] local 192.168.1.10 port 5001 connected with 192.168.1.232 port 38169
> [ ID] Interval       Transfer     Bandwidth
> [  4]  0.0-10.0 sec   112 MBytes  94.1 Mbits/sec
> 
> That's great ! with this patchset, we can now run a server with a
> vanilla kernel ( who needs more that a serial port and ethernet,
> really ? ;) )
> 
> Tested-by: Richard Genoud <richard.genoud@gmail.com>

Thanks for testing this.

Did you look at the load while iperf was running? I guess we can expect
it to be pretty high since it runs without DMA.

Maxime

-- 
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
