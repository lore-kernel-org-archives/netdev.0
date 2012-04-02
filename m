From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: dont overwrite settings for PHY Quick link
Date: Mon, 02 Apr 2012 18:42:05 -0400 (EDT)
Message-ID: <20120402.184205.386761801119825958.davem@davemloft.net>
References: <20120330172859.GB2703@Neptun>
	<20120402153818.40e34c2c@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LinoSanfilippo@gmx.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120402153818.40e34c2c@s6510.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 2 Apr 2012 15:38:18 -0700

> On Fri, 30 Mar 2012 19:28:59 +0200
> Lino Sanfilippo <LinoSanfilippo@gmx.de> wrote:
> 
>> This patch corrects a bug in function sky2_open() of the Marvell Yukon 2 driver
>> in which the settings for PHY quick link are overwritten.
>> 
>> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
 ...
> Acked-by: Stephen Hemminger <shemminger@vyattta.com>

Applied and queued up for -stable.

> Surprised that gcc did not detect the "or" of uninitialized value.

Especially since it warns for so much crap it shouldn't :-)
