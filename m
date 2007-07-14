From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] cleanup congestion control options
Date: Sat, 14 Jul 2007 09:10:34 +0200
Message-ID: <20070714071034.GG3565@stusta.de>
References: <20070714040953.GE3565@stusta.de> <20070713.235442.75191469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:60762 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751891AbXGNHLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 03:11:03 -0400
Content-Disposition: inline
In-Reply-To: <20070713.235442.75191469.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2007 at 11:54:42PM -0700, David Miller wrote:
> From: Adrian Bunk <bunk@stusta.de>
> Date: Sat, 14 Jul 2007 06:09:54 +0200
> 
> > This patch contains the following cleanups:
> > - note in the prompt if an option depends on EXPERIMENTAL
> > - remove "default n"s that didn't have any effect
> > - remove "default m"s from options under TCP_CONG_ADVANCED:
> >   if you manually choose congestion control modules you should
> >   know which ones you want
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> I'm not so sure about any of this, sorry Adrian, I'm
> not applying this.

What exactly are you not sure of?
- noting the experimental status in the prompt is a common convention
  in the kernel
- "default n"s like here are nops serving no purpose

This leaves only the removal of the "default m"s which I thought would 
be non-controversial since people seeing these options should know best
what they need.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

