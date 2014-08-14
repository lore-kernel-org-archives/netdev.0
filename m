From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: Intel wireless microcode problem..
Date: Thu, 14 Aug 2014 08:50:49 -0700
Message-ID: <CANUX_P19EOs1Qmn6MY=wvHSpkMUANLaa1R3dd0v4duqOYy-_=w@mail.gmail.com>
References: <CA+55aFxdt-9e9X0EYCu2Ku8sSTspUGPk5qKa72XH63zrkdPthw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:40394 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755103AbaHNPuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 11:50:51 -0400
In-Reply-To: <CA+55aFxdt-9e9X0EYCu2Ku8sSTspUGPk5qKa72XH63zrkdPthw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

On Thu, Aug 14, 2014 at 8:05 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Ok, so it seems the current merge window introduces some horrid intel
> microcode problem, because I don't seem to see this with 3.16. But
> maybe that's just happenstance.
>
> Any ideas? This fills up all the logs etc.
>
>                       Linus
>
> ---
>
> iwlwifi 0000:01:00.0: L1 Disabled; Enabling L0S
> iwlwifi 0000:01:00.0: L1 Disabled; Enabling L0S
> iwlwifi 0000:01:00.0: Microcode SW error detected.  Restarting 0x2000000.
> iwlwifi 0000:01:00.0: CSR values:
> iwlwifi 0000:01:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
> iwlwifi 0000:01:00.0:        CSR_HW_IF_CONFIG_REG: 0X40489204
> iwlwifi 0000:01:00.0:          CSR_INT_COALESCING: 0X80000040
> iwlwifi 0000:01:00.0:                     CSR_INT: 0X00000000
> iwlwifi 0000:01:00.0:                CSR_INT_MASK: 0X00000000
> iwlwifi 0000:01:00.0:           CSR_FH_INT_STATUS: 0X00000000
> iwlwifi 0000:01:00.0:                 CSR_GPIO_IN: 0X00000000
> iwlwifi 0000:01:00.0:                   CSR_RESET: 0X00000000
> iwlwifi 0000:01:00.0:                CSR_GP_CNTRL: 0X080403c5
> iwlwifi 0000:01:00.0:                  CSR_HW_REV: 0X00000144
> iwlwifi 0000:01:00.0:              CSR_EEPROM_REG: 0X00000000
> iwlwifi 0000:01:00.0:               CSR_EEPROM_GP: 0X80000000
> iwlwifi 0000:01:00.0:              CSR_OTP_GP_REG: 0X803a0000
> iwlwifi 0000:01:00.0:                 CSR_GIO_REG: 0X00080044
> iwlwifi 0000:01:00.0:            CSR_GP_UCODE_REG: 0X00000000
> iwlwifi 0000:01:00.0:           CSR_GP_DRIVER_REG: 0X00000000
> iwlwifi 0000:01:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
> iwlwifi 0000:01:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
> iwlwifi 0000:01:00.0:                 CSR_LED_REG: 0X00000060
> iwlwifi 0000:01:00.0:        CSR_DRAM_INT_TBL_REG: 0X880d8e9d
> iwlwifi 0000:01:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
> iwlwifi 0000:01:00.0:             CSR_ANA_PLL_CFG: 0Xd55555d5
> iwlwifi 0000:01:00.0:      CSR_MONITOR_STATUS_REG: 0X3d0801bd
> iwlwifi 0000:01:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
> iwlwifi 0000:01:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
> iwlwifi 0000:01:00.0: FH register values:
> iwlwifi 0000:01:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X0d42d300
> iwlwifi 0000:01:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X00d42d20
> iwlwifi 0000:01:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X00000028
> iwlwifi 0000:01:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80801114
> iwlwifi 0000:01:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
> iwlwifi 0000:01:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X07030000
> iwlwifi 0000:01:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
> iwlwifi 0000:01:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
> iwlwifi 0000:01:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
> iwlwifi 0000:01:00.0: Start IWL Error Log Dump:
> iwlwifi 0000:01:00.0: Status: 0x00000000, count: 6
> iwlwifi 0000:01:00.0: Loaded firmware version: 23.214.9.0
> iwlwifi 0000:01:00.0: 0x0000277B | ADVANCED_SYSASSERT
> iwlwifi 0000:01:00.0: 0x00A002A0 | uPc
> iwlwifi 0000:01:00.0: 0x00000000 | branchlink1
> iwlwifi 0000:01:00.0: 0x00000BA4 | branchlink2
> iwlwifi 0000:01:00.0: 0x000166A4 | interruptlink1
> iwlwifi 0000:01:00.0: 0x004C0648 | interruptlink2
> iwlwifi 0000:01:00.0: 0x00000021 | data1
> iwlwifi 0000:01:00.0: 0x00000016 | data2
> iwlwifi 0000:01:00.0: 0xDEADBEEF | data3
> iwlwifi 0000:01:00.0: 0x003CC2EC | beacon time
> iwlwifi 0000:01:00.0: 0x00033D3D | tsf low
> iwlwifi 0000:01:00.0: 0x00000000 | tsf hi
> iwlwifi 0000:01:00.0: 0x00000000 | time gp1
> iwlwifi 0000:01:00.0: 0x00033D3D | time gp2
> iwlwifi 0000:01:00.0: 0x00000000 | time gp3
> iwlwifi 0000:01:00.0: 0x000417D6 | uCode version
> iwlwifi 0000:01:00.0: 0x00000144 | hw version
> iwlwifi 0000:01:00.0: 0x40489204 | board version
> iwlwifi 0000:01:00.0: 0x0000001C | hcmd
> iwlwifi 0000:01:00.0: 0x00022000 | isr0
> iwlwifi 0000:01:00.0: 0x01000000 | isr1
> iwlwifi 0000:01:00.0: 0x00000002 | isr2
> iwlwifi 0000:01:00.0: 0x004058C0 | isr3
> iwlwifi 0000:01:00.0: 0x00000001 | isr4
> iwlwifi 0000:01:00.0: 0x00000110 | isr_pref
> iwlwifi 0000:01:00.0: 0x00000000 | wait_event
> iwlwifi 0000:01:00.0: 0x00000850 | l2p_control
> iwlwifi 0000:01:00.0: 0x00018000 | l2p_duration
> iwlwifi 0000:01:00.0: 0x0000003F | l2p_mhvalid
> iwlwifi 0000:01:00.0: 0x00000081 | l2p_addr_match
> iwlwifi 0000:01:00.0: 0x00000005 | lmpm_pmg_sel
> iwlwifi 0000:01:00.0: 0x18051651 | timestamp
> iwlwifi 0000:01:00.0: 0x00002830 | flow_handler

Thanks for your report. Someone else complained too. I am currently
travelling, but I am currently trying to reproduce.
I will report  back when I have something useful to share.

In the meantime - you can try this firmware:

https://git.kernel.org/cgit/linux/kernel/git/egrumbach/linux-firmware.git/log/?h=Core6

Of course, even if this one does work, we'll still make sure that your
current firmware will work with the current driver.

Thank you.
