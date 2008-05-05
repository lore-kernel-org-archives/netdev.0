From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [2.6 patch] make IWLWIFI a tristate
Date: Mon, 5 May 2008 22:42:45 +0300
Message-ID: <20080505194245.GA1544@cs181133002.pp.htv.fi>
References: <87zlrgl09s.fsf@sparse.dyndns.org> <1209435597.2624.35.camel@debian.sh.intel.com> <20080505182516.GM17139@cs181133002.pp.htv.fi> <20080505.124020.173231796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yi.zhu@intel.com, jason@acm.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:38038 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518AbYEETnx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 15:43:53 -0400
Content-Disposition: inline
In-Reply-To: <20080505.124020.173231796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 05, 2008 at 12:40:20PM -0700, David Miller wrote:
> From: Adrian Bunk <bunk@kernel.org>
> Date: Mon, 5 May 2008 21:25:16 +0300
> 
> > IWLWIFI should be a tristate so that if IWLCORE and/or IWL3945 are m
> > and none of them is y kbuild doesn't create an empty 
> > drivers/net/wireless/built-in.o
> > 
> > This patch also removes the pointless "default n".
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> I'll let this sit and cook for a while so that others can
> review and test this patch.  We've had enough churn in this
> area already :-)

No need to hurry, what it fixes is purely cosmetic.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

