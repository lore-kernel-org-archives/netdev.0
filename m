From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: call netif_napi_del at errpaths and at driver
 unload
Date: Fri, 01 Jun 2012 18:44:57 -0400 (EDT)
Message-ID: <20120601.184457.312806072581031622.davem@davemloft.net>
References: <1338465080-22720-1-git-send-email-devendra.aaru@gmail.com>
	<20120601.142531.544977894901194434.davem@davemloft.net>
	<20120601192944.GA21881@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devendra.aaru@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120601192944.GA21881@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 1 Jun 2012 21:29:44 +0200

> David Miller <davem@davemloft.net> :
> [...]
>> Francois, I'm assuming you will merge this to me after you've
>> done some testing.
> 
> You can apply it directly.
> 
> I have done several loops both with a forced error patch and the normal
> removal of the module without problem. No trivial crash. Four 816x network
> adapters. Reference one still comes up.

Ok, applied, thanks.
