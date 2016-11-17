From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/3] net: fsl: Allow most drivers to be
 built with COMPILE_TEST
Date: Thu, 17 Nov 2016 11:27:38 -0500 (EST)
Message-ID: <20161117.112738.557624953336530341.davem@davemloft.net>
References: <0216ebc6-1889-6ca7-974c-90524ed61651@gmail.com>
        <20161117013823.ne3f3dpvs64j5gmw@wfg-t540p.sh.intel.com>
        <2379973.pinmoxev18@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkp@intel.com, f.fainelli@gmail.com, kbuild-all@01.org,
        netdev@vger.kernel.org, mw@semihalf.com,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39852 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932896AbcKQRG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:06:59 -0500
In-Reply-To: <2379973.pinmoxev18@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 17 Nov 2016 11:47:02 +0100

> On Thursday, November 17, 2016 9:38:23 AM CET Fengguang Wu wrote:
>> include/asm-generic/io.h conditionally defines iounmap() to be an
>> empty inline function, which may explain the warning on sh4.
>> 
>> General speaking, it's a false warning. The solution could be to teach
>> the robot to ignore such 'unused variable' warnings in non-x86 archs.
> 
> I think we should change the iounmap stub macro into an inline function.

Agreed.
