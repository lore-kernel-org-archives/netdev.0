From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH] [IrDA] Fix IrDA build failure
Date: Mon, 16 Jul 2007 14:07:44 +0200
Message-ID: <20070716120744.GD3653@stusta.de>
References: <20070716111715.GB22757@mail.solidboot.com> <20070716115624.GA4492@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Samuel Ortiz <samuel.ortiz@solidboot.com>, davem@davemloft.net,
	eric.y.miao@gmail.com, sam@ravnborg.org, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net, stable@kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:34517 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755592AbXGPMI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 08:08:26 -0400
Content-Disposition: inline
In-Reply-To: <20070716115624.GA4492@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16, 2007 at 03:56:26PM +0400, Evgeniy Polyakov wrote:
> Hi Samuel.
> 
> On Mon, Jul 16, 2007 at 02:17:15PM +0300, Samuel Ortiz (samuel.ortiz@solidboot.com) wrote:
> > This is due to the irda_init fix recently added, where we call __exit
> > routines from an __init one. It is a build failure that I didn't catch
> > because it doesn't show up when building IrDA as a module. My apologies
> > for that.
> 
> What about having all of them __devinit/__devexit?

That would be completely wrong.

> 	Evgeniy Polyakov

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

