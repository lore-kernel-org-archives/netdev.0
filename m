From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH] net: use msecs_to_jiffies for conversion to jiffies
Date: Mon, 25 May 2015 07:50:25 +0200
Message-ID: <20150525055025.GD1397@opentech.at>
References: <1432388616-22785-1-git-send-email-hofrat@osadl.org> <20150524.161029.184486397241230288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hofrat@osadl.org, samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150524.161029.184486397241230288.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 24 May 2015, David Miller wrote:

> From: Nicholas Mc Guire <hofrat@osadl.org>
> Date: Sat, 23 May 2015 15:43:36 +0200
> 
> > API compliance scanning with coccinelle flagged:
> > ./net/irda/timer.c:63:35-37: use of msecs_to_jiffies probably perferable
> > 
> > Converting milliseconds to jiffies by "val * HZ / 1000" technically
> > is not a clean solution as it does not handle all corner cases correctly.
> > By changing the conversion to use msecs_to_jiffies(val) conversion is
> > correct in all cases. Further the () around the arithmetic expression
> > was dropped.
> > 
> > Patch was compile tested for x86_64_defconfig + CONFIG_IRDA=m
> > 
> > Patch is against 4.1-rc4 (localversion-next is -next-20150522)
> > 
> > Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> 
> The appropriate subsystem prefix for this change is not "net: "
> but rather "irda: ", please update your Subject line accordingly
> and resubmit.
>
sorry - the net: cam from looking at the output of 
hofrat@debian:~/git/linux-next$ git log --oneline net/irda/timer.c
d82603c treewide: Replace incomming with incoming in all comments and strings
9ffc93f Remove all #inclusions of asm/system.h
25985ed Fix common misspellings
5eaa65b net: Make static
db955170 more UTF-8 conversions
6819bc2 [NET] IRDA: Fix whitespace errors.
6ab3d56 Remove obsolete #include <linux/config.h>

where it was not really clear what prefix to use - and net: seemed the most
fitting. will fix it up and resend.

thx!
hofrat
