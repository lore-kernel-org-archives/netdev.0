From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: fsl: Allow most drivers to be built
 with COMPILE_TEST
Date: Tue, 15 Nov 2016 16:34:46 -0800
Message-ID: <02d29eb5-5ed2-1c50-9a1f-28c0ee01a761@gmail.com>
References: <201611160819.GP35xFRR%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        mw@semihalf.com, arnd@arndb.de, gregory.clement@free-electrons.com,
        Shaohui.Xie@freescale.com, Igal.Liberman@freescale.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36640 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752609AbcKPAet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:34:49 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so13055488pgx.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 16:34:49 -0800 (PST)
In-Reply-To: <201611160819.GP35xFRR%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2016 04:24 PM, kbuild test robot wrote:
> Hi Florian,
> 
> [auto build test WARNING on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Florian-Fainelli/net-ethernet-Allow-Marvell-Freescale-to-COMPILE_TEST/20161116-024633
> config: i386-allmodconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
>>> drivers/net/ethernet/freescale/gianfar_ptp.c:75:0: warning: "FS" redefined
>     #define FS                    (1<<28) /* FIPER start indication */
>     
>    In file included from arch/x86/include/uapi/asm/ptrace.h:5:0,
>                     from arch/x86/include/asm/ptrace.h:6,
>                     from arch/x86/include/asm/math_emu.h:4,
>                     from arch/x86/include/asm/processor.h:11,
>                     from include/linux/mutex.h:19,
>                     from include/linux/kernfs.h:13,
>                     from include/linux/sysfs.h:15,
>                     from include/linux/kobject.h:21,
>                     from include/linux/device.h:17,
>                     from drivers/net/ethernet/freescale/gianfar_ptp.c:23:
>    arch/x86/include/uapi/asm/ptrace-abi.h:15:0: note: this is the location of the previous definition
>     #define FS 9
>     

Fixed, resubmitting.
-- 
Florian
