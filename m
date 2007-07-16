From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH] [IrDA] Fix IrDA build failure
Date: Mon, 16 Jul 2007 15:05:19 +0200
Message-ID: <20070716130519.GE3653@stusta.de>
References: <20070716111715.GB22757@mail.solidboot.com> <20070716115624.GA4492@2ka.mipt.ru> <20070716120744.GD3653@stusta.de> <20070716121708.GA24483@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Samuel Ortiz <samuel.ortiz@solidboot.com>, davem@davemloft.net,
	eric.y.miao@gmail.com, sam@ravnborg.org, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net, stable@kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:34566 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758850AbXGPNF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 09:05:59 -0400
Content-Disposition: inline
In-Reply-To: <20070716121708.GA24483@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16, 2007 at 04:17:08PM +0400, Evgeniy Polyakov wrote:
> On Mon, Jul 16, 2007 at 02:07:44PM +0200, Adrian Bunk (bunk@stusta.de) wrote:
> > > What about having all of them __devinit/__devexit?
> > 
> > That would be completely wrong.
> 
> Hi Adrian.

Hi Evgeniy,

> Then why should irda have __init/__exit at first point

for code that only gets called during driver loading resp. driver 
unloading.

> - replacing that
> with appropriate 'dev' prefix I suggested.

You seem to misunderstand what the "dev" prefix is doing.

> 	Evgeniy Polyakov

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

