From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2.6.22-rc7 0/4] phy/gianfar: Fixes for gianfar and vitesse RGMII-ID support
Date: Tue, 17 Jul 2007 00:16:27 -0500
Message-ID: <CAD6C707-84F6-4355-A514-B9EBB565B4F9@kernel.crashing.org>
References: <1184635621688-git-send-email-afleming@freescale.com> <469C4E7B.6050401@garzik.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	Paul Mackerras <paulus@samba.org>,
	netdev <netdev@vger.kernel.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	Jeff Garzik <jeff@garzik.org>, stable@kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58270 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752314AbXGQFQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2007 01:16:30 -0400
In-Reply-To: <469C4E7B.6050401@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg,

Can you look at pulling these fixes for the next 2.6.22.x stable  
release.

- k

On Jul 17, 2007, at 12:07 AM, Jeff Garzik wrote:

> Andy Fleming wrote:
>> A few bugs in the Vitesse PHY driver were found on the 8641D HPCN  
>> board.
>> Originally, they were masked by a bug in the PHY Lib which was  
>> fixed by patch 5f708dd91d15876e26d7a57f97a255cedffca463 (Fix  
>> phy_id for Vitesse 824x PHY).
>> That patch allowed the Vitesse PHY to bind on the 8641D HPCN  
>> board, thereby
>> exposing a bug in the interrupt handling and a bug in the  
>> configuration of
>> the PHY.  This sequence of patches fixes the irq handling bug,  
>> then fixes the configuration bug in 3 places:
>> 1) The Vitesse PHY driver
>> 2) The gianfar driver (needs to pass in the mode correctly for  
>> internal delay)
>> 3) The OF device tree for arch/powerpc boards
>> You can apply the following patches, or pull them directly:
>> The following changes since commit  
>> c5e3ae8823693b260ce1f217adca8add1bc0b3de:
>>   Ayaz Abdulla (1):
>>         forcedeth bug fix: realtek phy
>> are found in the git repository at:
>>   http://opensource.freescale.com/pub/scm/linux-2.6-85xx.git netdev
>> Andy Fleming (4):
>>       Fix Vitesse 824x PHY interrupt acking
>>       Add phy-connection-type to gianfar nodes
>>       Fix Vitesse RGMII-ID support
>>       Fix RGMII-ID handling in gianfar
>>  Documentation/powerpc/booting-without-of.txt |    6 +++
>>  arch/powerpc/boot/dts/mpc8641_hpcn.dts       |    4 ++
>>  arch/powerpc/sysdev/fsl_soc.c                |    9 +++++
>>  drivers/net/gianfar.c                        |   12 ++++++-
>>  drivers/net/phy/vitesse.c                    |   46 ++++++++++++++ 
>> +++++++++---
>>  include/linux/fsl_devices.h                  |    1 +
>>  6 files changed, 72 insertions(+), 6 deletions(-)
>
> pulled
>

