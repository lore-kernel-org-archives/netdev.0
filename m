From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: remove duplicate #include
Date: Wed, 28 Oct 2009 22:52:17 -0700 (PDT)
Message-ID: <20091028.225217.78322944.davem@davemloft.net>
References: <alpine.LRH.2.00.0910280910250.24555@sbhatewara-dev1.eng.vmware.com>
	<20091028.222901.187567993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weiyi.huang@gmail.com,
	pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55586
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755333AbZJ2Fvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 01:51:53 -0400
In-Reply-To: <20091028.222901.187567993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 28 Oct 2009 22:29:01 -0700 (PDT)

> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> Date: Wed, 28 Oct 2009 09:30:40 -0700 (PDT)
> 
>> 
>> Remove duplicate headerfile includes from vmxnet3_int.h
>> 
>> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
>> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
>> Signed-off-by: Bhavesh Davda <davda@vmware.com>
> 
> Applied.

Guys, I'd like to remove the X86 Kconfig requirement for this
driver.  There really isn't any x86 specific code in the
driver, it uses only standard PCI and networking APIs to function.

I know the virtual hardware won't be seen on other platforms,
but allowing the driver to get build tested on non-x86 platforms
helps me a lot.  I do all of my build verifications on sparc64
for example.
