From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v3 2/3] net: fsl: Allow most drivers to be built with COMPILE_TEST
Date: Thu, 17 Nov 2016 11:47:02 +0100
Message-ID: <2379973.pinmoxev18@wuerfel>
References: <201611161135.ksuIHp17%fengguang.wu@intel.com> <0216ebc6-1889-6ca7-974c-90524ed61651@gmail.com> <20161117013823.ne3f3dpvs64j5gmw@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, kbuild-all@01.org,
        netdev@vger.kernel.org, davem@davemloft.net, mw@semihalf.com,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com
To: Fengguang Wu <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:55931 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2992846AbcKQKrb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 05:47:31 -0500
In-Reply-To: <20161117013823.ne3f3dpvs64j5gmw@wfg-t540p.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, November 17, 2016 9:38:23 AM CET Fengguang Wu wrote:
> >
> >Right here.
> >
> >What compiler version is this?
> 
> Compiler is sh4-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705.
> 
> include/asm-generic/io.h conditionally defines iounmap() to be an
> empty inline function, which may explain the warning on sh4.
> 
> General speaking, it's a false warning. The solution could be to teach
> the robot to ignore such 'unused variable' warnings in non-x86 archs.

I think we should change the iounmap stub macro into an inline function.
Does this only happen on sh or other architectures too?

I certainly wouldn't want the warning to be ignored on ARM, or in
general on all architectures other than x86.

	Arnd
