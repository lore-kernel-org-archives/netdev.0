From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 03/12] net-next: mediatek: add embedded switch
 driver (ESW)
Date: Fri, 26 Feb 2016 12:35:10 -0500 (EST)
Message-ID: <20160226.123510.2183497788787486032.davem@davemloft.net>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
	<1456496504-50429-4-git-send-email-blogic@openwrt.org>
	<20160226151813.GD12022@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: blogic@openwrt.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	matthias.bgg@gmail.com, steven.liu@mediatek.com,
	Carlos.Huang@mediatek.com, Fred.Chang@mediatek.com
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160226151813.GD12022@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 26 Feb 2016 16:18:13 +0100

> On Fri, Feb 26, 2016 at 03:21:35PM +0100, John Crispin wrote:
>> The ESW is found in many of the old 100mbit MIPS based SoCs. it has 5
>> external ports, 1 cpu port and 1 further port that the internal HW
>> offloading engine connects to.
>> 
>> This driver is very basic and only provides basic init and irq support.
>> The SoC and switch core both have support for a special tag making DSA
>> support possible.
> 
> Hi Crispin
> 
> There was recently a discussion about adding switches without using
> DSA or switchdev. It was pretty much decided we would not accept such
> drivers.
> 
> Sorry

+1
