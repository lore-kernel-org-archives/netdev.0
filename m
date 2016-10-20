From: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Subject: Re: Intel Wireless 7260 Microcode SW error detected
Date: Thu, 20 Oct 2016 06:59:15 +0300
Message-ID: <1476935955.7845.3.camel@coelho.fi>
References: <41dbbe14-3098-551d-6c34-0a3654bafca9@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Billes Tibor <tbilles-KK0ffGbhmjU@public.gmane.org>, linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <41dbbe14-3098-551d-6c34-0a3654bafca9-KK0ffGbhmjU@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tibor,

On Sun, 2016-10-16 at 20:08 +0200, Billes Tibor wrote:
> I have Lenovo laptop with an Intel Wireless 7260 wifi module and the 
> latest stable kernel 4.8.1. I was playing a movie from an sshfs mounted 
> file system, when the movie just froze and my network stopped working. 
> Dmesg said 'Microcode SW error detected'. Below is my full `dmesg -r` 
> output. I probably will not be able to reproduce this behaviour, because 
> it did not happen in the past, and it seems to work fine after reboot.

Can you file a bug in bugzilla so we can track this? It seems to be a
firmware problem that we'll have to investigate.  We have instructions
on how to report here:

https://wireless.wiki.kernel.org/en/users/drivers/iwlwifi/debugging


> Is there anything more that I can do to help you debug this?

It would be nice if you could enable firmware debugging so that, if
this happens again, we'll have the appropriate FW logs to investigate
it further.  There are instructions on how to enable it in the
"Firmware Debugging" section of that wiki page.

Please make sure you read and understand the privacy aspects of
submitting firmware debugging data, as explained here:

https://wireless.wiki.kernel.org/en/users/drivers/iwlwifi/debugging#privacy_aspects


> <3>[37750.190201] iwlwifi 0000:08:00.0: Microcode SW error detected.  
> Restarting 0x2000000.
> <3>[37750.190206] iwlwifi 0000:08:00.0: CSR values:
> <3>[37750.190207] iwlwifi 0000:08:00.0: (2nd byte of CSR_INT_COALESCING 
> is CSR_INT_PERIODIC_REG)
> <3>[37750.190212] iwlwifi 0000:08:00.0: CSR_HW_IF_CONFIG_REG: 0X40489204
> <3>[37750.190226] iwlwifi 0000:08:00.0: CSR_INT_COALESCING: 0X80000040
> <3>[37750.190239] iwlwifi 0000:08:00.0: CSR_INT: 0X00000000
> <3>[37750.190253] iwlwifi 0000:08:00.0: CSR_INT_MASK: 0X00000000
> <3>[37750.190267] iwlwifi 0000:08:00.0: CSR_FH_INT_STATUS: 0X00000000
> <3>[37750.190281] iwlwifi 0000:08:00.0: CSR_GPIO_IN: 0X00000000
> <3>[37750.190294] iwlwifi 0000:08:00.0: CSR_RESET: 0X00000000
> <3>[37750.190308] iwlwifi 0000:08:00.0: CSR_GP_CNTRL: 0X080403c5
> <3>[37750.190322] iwlwifi 0000:08:00.0: CSR_HW_REV: 0X00000144
> <3>[37750.190336] iwlwifi 0000:08:00.0: CSR_EEPROM_REG: 0X00000000
> <3>[37750.190350] iwlwifi 0000:08:00.0: CSR_EEPROM_GP: 0X80000000
> <3>[37750.190363] iwlwifi 0000:08:00.0: CSR_OTP_GP_REG: 0X803a0000
> <3>[37750.190377] iwlwifi 0000:08:00.0: CSR_GIO_REG: 0X001f0042
> <3>[37750.190391] iwlwifi 0000:08:00.0: CSR_GP_UCODE_REG: 0X00000000
> <3>[37750.190405] iwlwifi 0000:08:00.0: CSR_GP_DRIVER_REG: 0X00000000
> <3>[37750.190419] iwlwifi 0000:08:00.0: CSR_UCODE_DRV_GP1: 0X00000000
> <3>[37750.190432] iwlwifi 0000:08:00.0: CSR_UCODE_DRV_GP2: 0X00000000
> <3>[37750.190446] iwlwifi 0000:08:00.0: CSR_LED_REG: 0X00000060
> <3>[37750.190460] iwlwifi 0000:08:00.0: CSR_DRAM_INT_TBL_REG: 0X881530a3
> <3>[37750.190474] iwlwifi 0000:08:00.0: CSR_GIO_CHICKEN_BITS: 0X27800200
> <3>[37750.190488] iwlwifi 0000:08:00.0: CSR_ANA_PLL_CFG: 0Xd55555d5
> <3>[37750.190501] iwlwifi 0000:08:00.0: CSR_MONITOR_STATUS_REG: 0X3d0801bd
> <3>[37750.190515] iwlwifi 0000:08:00.0: CSR_HW_REV_WA_REG: 0X0001001a
> <3>[37750.190529] iwlwifi 0000:08:00.0: CSR_DBG_HPET_MEM_REG: 0Xffff0010
> <3>[37750.190530] iwlwifi 0000:08:00.0: FH register values:
> <3>[37750.190552] iwlwifi 0000:08:00.0: FH_RSCSR_CHNL0_STTS_WPTR_REG: 
> 0X15005f00
> <3>[37750.190566] iwlwifi 0000:08:00.0: FH_RSCSR_CHNL0_RBDCB_BASE_REG: 
> 0X015005e0
> <3>[37750.190580] iwlwifi 0000:08:00.0: FH_RSCSR_CHNL0_WPTR: 0X000000e8
> <3>[37750.190593] iwlwifi 0000:08:00.0: FH_MEM_RCSR_CHNL0_CONFIG_REG: 
> 0X80801114
> <3>[37750.190607] iwlwifi 0000:08:00.0: FH_MEM_RSSR_SHARED_CTRL_REG: 
> 0X000000fc
> <3>[37750.190621] iwlwifi 0000:08:00.0: FH_MEM_RSSR_RX_STATUS_REG: 
> 0X07030000
> <3>[37750.190635] iwlwifi 0000:08:00.0: 
> FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
> <3>[37750.190648] iwlwifi 0000:08:00.0: FH_TSSR_TX_STATUS_REG: 0X07ff0001
> <3>[37750.190662] iwlwifi 0000:08:00.0: FH_TSSR_TX_ERROR_REG: 0X00000000
> <3>[37750.190790] iwlwifi 0000:08:00.0: Start IWL Error Log Dump:
> <3>[37750.190791] iwlwifi 0000:08:00.0: Status: 0x00000000, count: 6
> <3>[37750.190793] iwlwifi 0000:08:00.0: Loaded firmware version: 16.242414.0

I recommend that you update your firmware to the latest version
(iwlwifi-7260-17.ucode) published in linux-firmware.git:

http://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git

While I'm not sure the issue you saw is solved by that, we do have lots
of other fixes in it that are worth the effort.


<3>[37750.190794] iwlwifi 0000:08:00.0: 0x0000307C | ADVANCED_SYSASSERT

I hadn't seen this for a while.  This is something related to the TX
queues and could have many different causes...

Thanks for reporting!

--
Cheers,
Luca.
