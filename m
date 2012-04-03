From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: fix missing register reset on error path in
 sky2_test_msi()
Date: Tue, 03 Apr 2012 17:08:41 -0400 (EDT)
Message-ID: <20120403.170841.1992774969352219317.davem@davemloft.net>
References: <20120403115547.799fcc1f@s6510.linuxnetplumber.net>
	<20120403.163008.1865240185992444794.davem@davemloft.net>
	<20120403135954.2131ab08@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LinoSanfilippo@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120403135954.2131ab08@s6510.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 3 Apr 2012 13:59:54 -0700

> On Tue, 03 Apr 2012 16:30:08 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Tue, 3 Apr 2012 11:55:47 -0700
>> 
>> > On Fri, 30 Mar 2012 19:36:16 +0200
>> > Lino Sanfilippo <LinoSanfilippo@gmx.de> wrote:
>> > 
>> >> In sky2_test_msi() the temporarily set SW IRQ in B0 register is not reset in case
>> >> that request_irq() fails.
>> >> With this patch we only set the interrupt mask if request_irq() was successful.
>> >> 
>> >> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
>> > 
>> > Ok, but this is a non-serious error case. If request_irq() fails here,
>> > the driver is going to fail to load and on the failure path of
>> > sky2_probe will reset the chip on the way out.
>> 
>> So, ACK for net-next?  Toss it?  What?
> 
> Put it in net-next, no need for net or stable.

Done, thanks.
