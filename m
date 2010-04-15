From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Wed, 14 Apr 2010 23:42:42 -0700 (PDT)
Message-ID: <20100414.234242.159666963.davem@davemloft.net>
References: <1270877380-23813-1-git-send-email-cpeterso@cpeterso.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mpm@selenic.com
To: cpeterso@cpeterso.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270877380-23813-1-git-send-email-cpeterso@cpeterso.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Peterson <cpeterso@cpeterso.com>
Date: Sat, 10 Apr 2010 01:29:40 -0400

> feature-removal-schedule.txt says a new /dev/random entropy model is planned 
> (for July 2009). Until then, this patch removes the few remaining uses of 
> IRQF_SAMPLE_RANDOM from drivers/net/*. 12 network drivers are affected, one 
> more than last year (netxen_nic_main.c). If idle servers need more entropy, 
> they ought to use a hardware RNG or an entropy-gathering userspace daemon.
> 
> Signed-off-by: Chris Peterson <cpeterso@cpeterso.com>

Well, that feature-removal-schedule.txt entry states that new
add_*_randomness() interfaces will be created such that things
like network devices can indicate what kind of entropy they
are providing.

Those interfaces have not yet been created as far as I can tell, and
the idea is that network drivers could use those not-yet-written new
interfaces.

Until that time I feel it does more harm than good to remove these
annotations since frankly there never ever was good agreement about
whether we should do this or not.

It may seem stupid and pointless to just do nothing, but at this time
I think that's still the best thing to do.

Therefore, I'm not applying your patch, sorry.
