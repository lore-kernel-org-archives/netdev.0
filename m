From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH v2] net: phy: spi_ks8995: add dependency on GPIO
Date: Fri, 19 Feb 2016 22:05:20 +0530
Message-ID: <56C74448.8080404@gmail.com>
References: <1455372195-10825-1-git-send-email-sudipm.mukherjee@gmail.com>	<20160216.203606.1431228679408727525.davem@davemloft.net>	<20160219082909.GA6312@sudip-pc> <20160219.111323.1588037348332012027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, netdev@vger.kernel.org,
	geert@linux-m68k.org, helmut.buchsbaum@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160219.111323.1588037348332012027.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 February 2016 09:43 PM, David Miller wrote:
> From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> Date: Fri, 19 Feb 2016 13:59:09 +0530
>
>> On Tue, Feb 16, 2016 at 08:36:06PM -0500, David Miller wrote:
>>> From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
>>> Date: Sat, 13 Feb 2016 19:33:15 +0530
>>>
>>>> The builds of allmodconfig of s390, m68k, tilegx, tilepro is failing
>>>> with the error:
>>>>   drivers/net/phy/spi_ks8995.c:477:3: error: implicit declaration of function 'gpiod_set_value'
>>>>   drivers/net/phy/spi_ks8995.c:477:19: error: implicit declaration of function 'gpio_to_desc'
>   ...
>> I think Arnd's patch is still not applied as we are still having build
>> failures for the implicit declarations. Or you want me to send v3 after
>> removing unnecessary linux/gpio.h include?
>
> It's definitely there in net-next, commit 27090cbdc345cd5fd6f6e57a8986c504c27e4d23
>

Ohhh.. ok.. linux-next is still using net-next from next-20160217, I 
hope Monday it will be fine.

regards
sudip
