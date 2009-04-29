From: Vladimir Barinov <vova.barinov@gmail.com>
Subject: Re: [PATCH 8/8 V2] MX27ADS: Add CS89x0 support
Date: Wed, 29 Apr 2009 11:03:36 +0400
Message-ID: <49F7FBC8.7090705@gmail.com>
References: <1240963177-23941-1-git-send-email-vbarinov@embeddedalley.com>	<1240963405-24007-1-git-send-email-vbarinov@embeddedalley.com> <20090428.231946.27173581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	linux-arm-kernel@lists.arm.linux.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:64872 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013AbZD2HDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 03:03:42 -0400
Received: by fk-out-0910.google.com with SMTP id 18so470518fkq.5
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 00:03:41 -0700 (PDT)
In-Reply-To: <20090428.231946.27173581.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

David Miller wrote:
> From: Vladimir Barinov <vova.barinov@gmail.com>
> Date: Wed, 29 Apr 2009 04:03:25 +0400
>
>   
>> Add CS89x0 net chip support for MX27ADS board
>>
>> Signed-off-by: Vladimir Barinov <vbarinov@embeddedalley.com>
>>     
>
> So what's the story with the apparent 7 patches that preceed this
> one and this one seems to depend upon?
>
> Context, please :)
>
>   
The patchset description is:

The following patch series makes transition to setup all pins at once in
platfrom code. Also it adds NAND, I2C, Framebuffer, SDHC, EXPIO(CPLD),
CS89x0 devices support for MX27ADS board.

The changes since V1:
- removed ifdefs around I2C
- put IRQF flags in request_irq for sdhc card detection


The patch series looks like:

0000-MX27ADS-support.patch
0001-MX27ADS-setup-all-pins-at-once-in-one-table.patch
0002-MX27ADS-Add-NAND-support.patch
0003-MX27ADS-Add-I2C-support.patch
0004-MX27ADS-Add-framebuffer-support.patch
0005-MX27ADS-Add-1-wire-support.patch
0006-MX27ADS-Add-SDHC-support.patch
0007-MX27ADS-Add-EXPIO-demux-support.patch
0008-MX27ADS-Add-CS89x0-support.patch

And the total diffstat for previous 7 patches is:
 arch/arm/mach-mx2/mx27ads.c                    |  368 
++++++++++++++++---------
 arch/arm/plat-mxc/include/mach/board-mx27ads.h |    3
 2 files changed, 238 insertions(+), 133 deletions(-)

So I think there were no sense to send first 7 patches to netdev list in 
this case :)

Sorry for inconvenience.

Regards,
Vladimir
