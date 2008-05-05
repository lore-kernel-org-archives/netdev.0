From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make IWLWIFI a tristate
Date: Mon, 05 May 2008 12:40:20 -0700 (PDT)
Message-ID: <20080505.124020.173231796.davem@davemloft.net>
References: <87zlrgl09s.fsf@sparse.dyndns.org>
	<1209435597.2624.35.camel@debian.sh.intel.com>
	<20080505182516.GM17139@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, jason@acm.org, netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35462
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752054AbYEETkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 15:40:20 -0400
In-Reply-To: <20080505182516.GM17139@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 5 May 2008 21:25:16 +0300

> IWLWIFI should be a tristate so that if IWLCORE and/or IWL3945 are m
> and none of them is y kbuild doesn't create an empty 
> drivers/net/wireless/built-in.o
> 
> This patch also removes the pointless "default n".
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

I'll let this sit and cook for a while so that others can
review and test this patch.  We've had enough churn in this
area already :-)
