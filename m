From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [net-next:master 1058/1060] qede_main.c:undefined reference to
 `tcp_gro_complete'
Date: Tue, 8 Mar 2016 06:55:19 +0000
Message-ID: <DM2PR11MB0124FA5B7C28C566906F355793B20@DM2PR11MB0124.namprd11.prod.outlook.com>
References: <201603080943.28WIidCr%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kbuild-all@01.org" <kbuild-all@01.org>,
	netdev <netdev@vger.kernel.org>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0140.outbound.protection.outlook.com ([207.46.100.140]:57504
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753859AbcCHHKD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 02:10:03 -0500
In-Reply-To: <201603080943.28WIidCr%fengguang.wu@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: kbuild test robot [mailto:fengguang.wu@intel.com]
> Sent: Tuesday, March 08, 2016 6:45 AM
> To: Manish Chopra <manish.chopra@qlogic.com>
> Cc: kbuild-all@01.org; netdev <netdev@vger.kernel.org>; Yuval Mintz
> <Yuval.Mintz@qlogic.com>
> Subject: [net-next:master 1058/1060] qede_main.c:undefined reference to
> `tcp_gro_complete'
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> master
> head:   d66ab51442211158b677c2f12310c314d9587f74
> commit: 55482edc25f0606851de42e73618f813f310d009 [1058/1060] qede: Add
> slowpath/fastpath support and enable hardware GRO
> config: x86_64-randconfig-s0-03080757 (attached as .config)
> reproduce:
>         git checkout 55482edc25f0606851de42e73618f813f310d009
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/built-in.o: In function `qede_rx_int':
> >> qede_main.c:(.text+0x6101a0): undefined reference to `tcp_gro_complete'
> 
> ---

Seems to be a false alarm ??
I tried compiling net-next with "make ARCH=x86_64" using attached ".config" after David applied the series.
I didn't see any error or warning as reported above.

Thanks,
Manish
